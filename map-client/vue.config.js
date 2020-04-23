process.env.VUE_APP_JSON_PATH = process.env.NODE_ENV === 'production'
  ? '/index.json'
  : 'index-mock.json'

module.exports = {
  publicPath: '/',
  outputDir: '../www-data/'
}
