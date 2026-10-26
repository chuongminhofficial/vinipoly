/**
 * Quickstart Example — ViniPoly DRM JavaScript/Node.js SDK (v1.1.3)
 * Usage: VINIPOLY_API_KEY="VP_..." node examples/js_quickstart.js
 */
const { ViniPolyClient, ViniPolyError } = require('../sdk/js/vinipoly_sdk.js');

const client = new ViniPolyClient({
  apiKey: process.env.VINIPOLY_API_KEY || 'VP_your_api_key_here',
});

async function main() {
  try {
    const info = await client.getAccountInfo();
    console.log('[Account Info]:', info);

    const history = await client.getUsageHistory();
    console.log(`[Recent Transactions]: ${history.length} records`);
  } catch (err) {
    if (err instanceof ViniPolyError) {
      console.error(`ViniPoly Error [HTTP ${err.statusCode}]: ${err.message}`);
    } else {
      console.error('Unexpected error:', err);
    }
  }
}

main();
