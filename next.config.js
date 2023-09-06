/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    swcMinify: true,
    output: 'standalone',
    compress: false,
    generateBuildId: async () => {
      // You can, for example, get the latest git commit hash here
      return 'my-build-id'
    },
  }
  

module.exports = nextConfig
