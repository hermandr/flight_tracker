'use client';

import { useState } from 'react';

interface Flight {
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

export default function Home() {
  const [query, setQuery] = useState('');
  const [flights, setFlights] = useState<Flight[] | null>(null);
  const [loading, setLoading] = useState(false);
  const [searched, setSearched] = useState(false);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;

    setLoading(true);
    setSearched(true);
    setFlights(null);

    try {
      const res = await fetch(`/api/flights?query=${encodeURIComponent(query)}`);
      const data = await res.json();
      setFlights(data);
    } catch (error) {
      console.error('Failed to fetch flights', error);
      setFlights([]);
    } finally {
      setLoading(false);
    }
  };

  const formatTime = (timeStr: string, timezone: string) => {
    try {
      return new Date(timeStr).toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit',
        timeZone: timezone,
        timeZoneName: 'short',
      });
    } catch (e) {
      return timeStr;
    }
  };

  const formatDate = (timeStr: string) => {
    try {
      return new Date(timeStr).toLocaleDateString('en-US', {
        weekday: 'short', month: 'short', day: 'numeric'
      });
    } catch (e) {
      return '';
    }
  }

  return (
    <main className="container">
      <h1 className="title">FlightTracker</h1>
      <p className="subtitle">Real-time flight status at your fingertips</p>

      <div className="search-container">
        <form onSubmit={handleSearch} className="input-group">
          <input
            type="text"
            className="search-input"
            placeholder="Enter flight number (e.g., AA123, BA456)"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />
          <button type="submit" className="search-button" disabled={loading}>
            {loading ? 'Searching...' : 'Search'}
          </button>
        </form>
      </div>

      <div className="results">
        {loading && <div className="loading">Accquiring Satellite Lock...</div>}

        {!loading && searched && flights && flights.length === 0 && (
          <div className="no-results">
            No flights found matching "{query}". Try "AA123" or "BA456".
          </div>
        )}

        {!loading && flights && flights.map((flight) => (
          <div key={`${flight.flightNumber}-${flight.departure.time}`} className="flight-card">
            <div className="flight-header">
              <span className="airline">{flight.airline}</span>
              <span className="flight-number">{flight.flightNumber}</span>
            </div>

            <div className="route">
              <div className="location departure">
                <span className="city">{flight.departure.city}</span>
                <span className="airport-code">{flight.departure.airport}</span>
                <div className="time">{formatTime(flight.departure.time, flight.departure.timezone)}</div>
                <div className="duration-text">{formatDate(flight.departure.time)}</div>
              </div>

              <div className="duration-container">
                <div className="duration-text">{flight.duration}</div>
                <div className="duration-line"></div>
              </div>

              <div className="location arrival">
                <span className="city">{flight.arrival.city}</span>
                <span className="airport-code">{flight.arrival.airport}</span>
                <div className="time">{formatTime(flight.arrival.time, flight.arrival.timezone)}</div>
                <div className="duration-text">{formatDate(flight.arrival.time)}</div>
              </div>
            </div>

            <div style={{ marginTop: '1rem', display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: '#94a3b8' }}>
              <span>Timezone: {flight.departure.timezone}</span>
              <span>Timezone: {flight.arrival.timezone}</span>
            </div>
          </div>
        ))}
      </div>
    </main>
  );
}
