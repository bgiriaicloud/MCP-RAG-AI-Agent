/** @type {import('next').NextConfig} */
const nextConfig = {
    output: 'standalone',
    env: {
        AGENT_SERVICE_URL: process.env.AGENT_SERVICE_URL || 'http://localhost:8000',
    },
};

export default nextConfig;
