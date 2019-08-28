<?php
$version = '1.0.0';
$placeholderName = 'Payment Gateway';
$name = $argv[1] ?? null;
$domain = $argv[2] ?? null;
$srcDir = 'src';
$buildDir = 'build';
$distDir = 'dist';

line();
highlight('Whitelabel Build Script');

/**
 * check workspace
 */
if (!file_exists($srcDir)) {
    line();
    error('Source directory does not exist');
    exit;
}

/**
 * validate name input
 */
if (empty($name)) {
    line();
    error('Name must not be empty');
    usage();
    exit;
}

/**
 * validate domain input
 */
$domain = filter_var($domain, FILTER_VALIDATE_DOMAIN, FILTER_FLAG_HOSTNAME);
if (empty($domain)) {
    line();
    error('Domain must not be empty');
    usage();
    exit;
}

/**
 * create replacement map
 */
$composerHashPrefix = md5(identifierCase($name) . '-' . $version);
$replacementMap = [
    // "Payment Gateway" -> "My Provider"
    $placeholderName => $name,
    // "PaymentGateway" -> "MyProvider" (namespaces and other identifiers)
    pascalCase($placeholderName) => pascalCase($name),
    // "paymentGateway" -> "myProvider"
    camelCase($placeholderName) => camelCase($name),
    // "paymentgateway" -> "myprovider"
    identifierCase($placeholderName) => identifierCase($name),
    // "payment-gateway" -> "my-provider"
    kebabCase($placeholderName) => kebabCase($name),
    // "payment_gateway" -> "my_provider"
    snakeCase($placeholderName) => snakeCase($name),
    // "PAYMENT_GATEWAY -> "MY_PROVIDER" (constants)
    constantCase($placeholderName) => constantCase($name),
    // "gateway.paymentgateway.cloud" -> "gateway.myprovider.com" (client xml namespace and endpoints)
    'gateway.paymentgateway.cloud' => $domain,
    // X.Y.Z -> 1.1.0
    'X.Y.Z' => $version,
    /**
     * Prefix composer autoloader names with a unique hash.
     * This prevents conflicts in case two whitelabel plugins, which were both
     * built from the same version of the source, are installed at the same time.
     */
    'ComposerStaticInit' => 'ComposerStaticInit' . $composerHashPrefix,
    'ComposerAutoloaderInit' => 'ComposerAutoloaderInit' . $composerHashPrefix,
];

/**
 * print replacement map and prompt user if planned changes are ok
 */
line();
foreach ($replacementMap as $old => $new) {
    line('    ' . $old . ' => ' . $new);
}
line();
prompt('OK?');

/**
 * clear existing build folder
 */
if (file_exists($buildDir)) {
    deleteDir($buildDir);
    info('Cleared build directory');
}

/**
 * build
 * copy source to build folder, clear existing if applicable
 * applies replacement map to folder names, file names and file contents while at it
 */
info('Building...');
build($srcDir, $buildDir, $replacementMap);
success('Done');

/**
 * create dist folder if needed
 */
if (!file_exists($distDir)) {
    mkdir($distDir);
    info('Created dist directory');
}

/**
 * zip build to myprovider.zip
 */
info('Creating zip file...');
zipBuildToDist($buildDir, $distDir, identifierCase($name) . '-' . $version, identifierCase($name));
success('Done');

exit;

/**
 * Helper functions below
 */

/**
 * print usage info
 */
function usage()
{
    warn('Usage: php build.php [name] [domain]');
    line('Example: php build.php "My Payment Provider" gateway.mypaymentprovider.com');
    line();
}

/**
 * @param string $string
 * @return string
 */
function camelCase($string)
{
    return lcfirst(pascalCase($string));
}

/**
 * @param string $string
 * @return string
 */
function kebabCase($string)
{
    return str_replace('_', '-', snakeCase($string));
}

/**
 * @param string $string
 * @return string
 */
function pascalCase($string)
{
    return ucfirst(str_replace(' ', '', ucwords(strtolower(preg_replace('/^a-z0-9]+/', ' ', $string)))));
}

/**
 * @param string $string
 * @return string
 */
function snakeCase($string)
{
    return strtolower(str_replace(' ', '_', ucwords(preg_replace('/^a-z0-9]+/', ' ', $string))));
}

/**
 * @param string $string
 * @return mixed
 */
function identifierCase($string)
{
    return strtolower(pascalCase($string));
}

/**
 * @param string $string
 * @return mixed
 */
function constantCase($string)
{
    return strtoupper(snakeCase($string));
}

/**
 * @param null $message
 */
function line($message = null)
{
    echo $message . "\n";
}

/**
 * @param null $message
 */
function error($message = null)
{
    echo "\e[0;31m[ERROR] " . $message . "\e[0m\n";
}

/**
 * @param null $message
 */
function warn($message = null)
{
    echo "\e[0;33m[WARN] " . $message . "\e[0m\n";
}

/**
 * @param null $message
 */
function info($message = null)
{
    echo "\e[0;36m[INFO] " . $message . "\e[0m\n";
}

/**
 * @param null $message
 */
function success($message = null)
{
    echo "\e[0;32m[SUCCESS] " . $message . "\e[0m\n";
}

/**
 * @param string $message
 */
function highlight($message)
{
    echo "\e[0;34m" . $message . "\e[0m\n";
}

/**
 * @param string $message
 */
function debug($message)
{
    echo "[SUCCESS] " . $message . "\n";
}

/**
 * @param string $message
 */
function prompt($message)
{
    echo "\e[0;35m" . $message . " [y/n]\e[0m\n";
    $handle = fopen("php://stdin", "r");
    $line = fgets($handle);
    if (trim($line) !== 'y') {
        warn('Abort');
        exit;
    }
    fclose($handle);
}

/**
 * @param string $src
 * @param string $dst
 * @param array $replacementMap
 */
function build($src, $dst, $replacementMap = [])
{
    $dir = opendir($src);
    @mkdir($dst);
    while (false !== ($file = readdir($dir))) {
        if (($file != '.') && ($file != '..')) {
            $srcFile = $src . '/' . $file;
            $destFile = $dst . '/' . applyReplacements($file, $replacementMap);
            if (is_dir($srcFile)) {
                build($srcFile, $destFile, $replacementMap);
            } else {
                copy($srcFile, $destFile);
                replaceContents($destFile, $replacementMap);
            }
        }
    }
    closedir($dir);
}

/**
 * @param string $file
 * @param array $replacementMap
 */
function replaceContents($file, $replacementMap)
{
    file_put_contents($file, applyReplacements(file_get_contents($file), $replacementMap));
}

/**
 * @param string $string
 * @param array $replacementMap
 * @return string
 */
function applyReplacements($string, $replacementMap)
{
    foreach ($replacementMap as $old => $new) {
        $string = str_replace($old, $new, $string);
    }
    return $string;
}

/**
 * @param string $dir
 */
function deleteDir($dir)
{
    if (empty($dir)) {
        return;
    }
    $dir = './' . $dir;
    $it = new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS);
    $files = new RecursiveIteratorIterator($it,
        RecursiveIteratorIterator::CHILD_FIRST);
    foreach ($files as $file) {
        if ($file->isDir()) {
            rmdir($file->getRealPath());
        } else {
            unlink($file->getRealPath());
        }
    }
    rmdir($dir);
}

/**
 * @param string $dir
 * @param string $destFile
 */
function zipBuildToDist($srcDir, $destDir, $filename, $directoryName)
{
    // Get real path for our folder
    $rootPath = realpath($srcDir);

    // Initialize archive object
    $zip = new ZipArchive();
    $zip->open($destDir . '/' . $filename . '.zip', ZipArchive::CREATE | ZipArchive::OVERWRITE);

    // Create recursive directory iterator
    /** @var SplFileInfo[] $files */
    $files = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($rootPath),
        RecursiveIteratorIterator::LEAVES_ONLY
    );
    foreach ($files as $name => $file) {

        // Skip directories (they would be added automatically)
        if (!$file->isDir()) {

            // Get real and relative path for current file
            $filePath = $file->getRealPath();
            $relativePath = $directoryName . '/' . substr($filePath, strlen($rootPath) + 1);

            // Add current file to archive
            $zip->addFile($filePath, $relativePath);
        }
    }

    // Zip archive will be created only after closing object
    $zip->close();
}
