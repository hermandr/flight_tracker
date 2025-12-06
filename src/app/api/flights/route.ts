import { NextResponse } from 'next/server';

export interface Flight {
    flightNumber: string;
    departure: {
        airport: string;
        time: string;
        timezone: string;
        city: string;
    };
    arrival: {
        airport: string;
        time: string;
        timezone: string;
        city: string;
    };
    duration: string;
    airline: string;
}

const API_KEY = '9315babc9a0a1f8648d71a07e64d59c4';
const API_URL = 'http://api.aviationstack.com/v1/flights';

function getCityFromTimezone(timezone: string | null): string {
    if (!timezone) return 'Unknown City';
    const parts = timezone.split('/');
    if (parts.length > 1) {
        return parts[parts.length - 1].replace(/_/g, ' ');
    }
    return timezone;
}

function calculateDuration(start: string, end: string): string {
    const startDate = new Date(start);
    const endDate = new Date(end);
    const diffMs = endDate.getTime() - startDate.getTime();

    if (isNaN(diffMs)) return 'N/A';

    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));

    return `${diffHours}h ${diffMinutes}m`;
}

export async function GET(request: Request) {
    const { searchParams } = new URL(request.url);
    const query = searchParams.get('query');

    if (!query) {
        return NextResponse.json([]);
    }

    try {
        const res = await fetch(`${API_URL}?access_key=${API_KEY}&flight_iata=${query}`);

        if (!res.ok) {
            throw new Error('Failed to fetch from aviationstack');
        }

        const data = await res.json();

        if (!data.data || !Array.isArray(data.data)) {
            return NextResponse.json([]);
        }

        const flights: Flight[] = data.data.map((flight: any) => ({
            flightNumber: flight.flight.iata,
            departure: {
                airport: flight.departure.iata,
                time: flight.departure.scheduled,
                timezone: flight.departure.timezone,
                city: getCityFromTimezone(flight.departure.timezone),
            },
            arrival: {
                airport: flight.arrival.iata,
                time: flight.arrival.scheduled,
                timezone: flight.arrival.timezone,
                city: getCityFromTimezone(flight.arrival.timezone),
            },
            duration: calculateDuration(flight.departure.scheduled, flight.arrival.scheduled),
            airline: flight.airline.name,
        }));

        return NextResponse.json(flights);

    } catch (error) {
        console.error('API Error:', error);
        return NextResponse.json({ error: 'Failed to fetch flight data' }, { status: 500 });
    }
}
