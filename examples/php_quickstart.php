<?php
/**
 * Quickstart Example — ViniPoly DRM PHP SDK (v1.1.3)
 * Usage: VINIPOLY_API_KEY="VP_..." php examples/php_quickstart.php
 */
require_once __DIR__ . '/../sdk/php/ViniPolySDK.php';

use ViniPolyDRM\ViniPolyClient;
use ViniPolyDRM\ViniPolyException;

try {
    $apiKey = getenv('VINIPOLY_API_KEY') ?: 'VP_your_api_key_here';
    $client = new ViniPolyClient($apiKey);

    $info = $client->getAccountInfo();
    print_r($info);
} catch (ViniPolyException $e) {
    echo "ViniPoly Error [HTTP {$e->statusCode}]: {$e->getMessage()}\n";
}
