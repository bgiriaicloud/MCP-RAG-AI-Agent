import { NextRequest, NextResponse } from 'next/server';

const AGENT_SERVICE_URL = process.env.AGENT_SERVICE_URL || 'http://localhost:8000';

export async function POST(request: NextRequest) {
    try {
        const body = await request.json();
        const { query } = body;

        if (!query) {
            return NextResponse.json(
                { error: 'Query is required' },
                { status: 400 }
            );
        }

        // Forward request to the Agent Service
        const response = await fetch(`${AGENT_SERVICE_URL}/agent/chat`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                query,
                session_id: request.headers.get('x-session-id') || 'default-session',
            }),
        });

        if (!response.ok) {
            throw new Error(`Agent service responded with status: ${response.status}`);
        }

        const data = await response.json();
        return NextResponse.json(data);
    } catch (error) {
        console.error('Error calling agent service:', error);
        return NextResponse.json(
            { error: 'Failed to process request', response: 'Sorry, I encountered an error.' },
            { status: 500 }
        );
    }
}
