/**
 * Load dependencies.
 */
const dotenv = require('dotenv');
const path = require('path');

/**
 * Configuration.
 */
dotenv.config();

/**
 * Plugins
 */
// production
const {CleanWebpackPlugin} = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const EslintWebpackPlugin = require('eslint-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

/**
 * Debug
 */
const debug = process.env.NODE_ENV !== 'production';

/**
 * Webpack initialize.
 */
module.exports = {
  context: path.join(__dirname, 'src'),
  devtool: debug ? 'inline-source-map' : false,
  devServer: {
    allowedHosts: [`www.${process.env.DOMAIN}`, process.env.DOMAIN],
    host: process.env.HOST || '0.0.0.0',
    port: process.env.PORT || 8080,
    sockPort: process.env.PORT_PUBLISHED || process.env.PORT || 8080,
    injectClient: false,
    watchOptions: {
      aggregateTimeout: 500, // delay before reloading
      poll: 1000, // enable polling since fsevents are not supported in docker
    },
  },
  mode: debug ? 'development' : 'production',
  entry: [
    './scripts/site.js',
    './styles/main.scss',
  ],
  module: {
    rules: [{
      test: /\.scss$/,
      use: [{
        loader: MiniCssExtractPlugin.loader,
        options: {
          publicPath: '/',
        },
      }, {
        loader: 'css-loader',
        options: {
          sourceMap: true,
        },
      }, {
        loader: 'sass-loader',
        options: {
          sourceMap: true,
        },
      }],
    }, {
      test: /\.js$/,
      exclude: /node_modules/,
      use: [{
        loader: 'babel-loader',
        options: {
          presets: ['env'],
        },
      }],
    }],
  },
  output: {
    filename: debug ? 'js/[name].js' : 'js/[name].[hash].min.js',
    path: path.join(__dirname, 'dist'),
    publicPath: '/',
  },
  plugins: [
    // globals
    new CleanWebpackPlugin(),
    new HtmlWebpackPlugin({
      template: 'index.html',
    }),
    new MiniCssExtractPlugin({
      filename: debug ? 'css/[name].css' : 'css/[name].[hash].css',
      chunkFilename: debug ? '[id].css' : '[id].[hash].css',
    }),
  ].concat(debug ? [
    // development only
    new EslintWebpackPlugin(),
  ] : [
    // production only
    new CopyWebpackPlugin({
      patterns: [
        { from: 'robots.txt' },
      ],
    }),
  ]),
};
