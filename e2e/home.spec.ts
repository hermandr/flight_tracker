import { test, expect } from '@playwright/test';

test.describe('Flight Tracker Home', () => {
    test.beforeEach(async ({ page }) => {
        // Mock the API response to ensure consistent results and avoid external API usage
        await page.route('/api/flights*', async route => {
            const url = route.request().url();

            // Check if it's a search for known flight
            if (url.includes('AA123')) {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify([
                        {
                            flightNumber: 'AA123',
                            departure: {
                                airport: 'JFK',
                                time: '2023-10-25T10:00:00+00:00',
                                timezone: 'America/New_York',
                                city: 'New York'
                            },
                            arrival: {
                                airport: 'LHR',
                                time: '2023-10-25T22:00:00+00:00',
                                timezone: 'Europe/London',
                                city: 'London'
                            },
                            duration: '7h 0m',
                            airline: 'American Airlines'
                        }
                    ])
                });
            }
            // Check if it's a search for empty results
            else if (url.includes('EMPTY')) {
                await route.fulfill({
                    status: 200,
                    contentType: 'application/json',
                    body: JSON.stringify([])
                });
            }
            else {
                await route.continue();
            }
        });

        await page.goto('/');
    });

    test('has title', async ({ page }) => {
        await expect(page).toHaveTitle(/Flight Tracker/);
        await expect(page.locator('h1.title')).toHaveText('FlightTracker');
    });

    test('can search for a flight', async ({ page }) => {
        // Fill the search input
        const searchInput = page.locator('input.search-input');
        await searchInput.fill('AA123');

        // Click search
        await page.click('button.search-button');

        // Wait for results
        const flightCard = page.locator('.flight-card').first();
        await expect(flightCard).toBeVisible();

        // Verify details
        await expect(flightCard).toContainText('AA123');
        await expect(flightCard).toContainText('New York');
        await expect(flightCard).toContainText('London');
        await expect(flightCard).toContainText('American Airlines');
    });

    test('shows no results message', async ({ page }) => {
        const searchInput = page.locator('input.search-input');
        await searchInput.fill('EMPTY');

        await page.click('button.search-button');

        const noResults = page.locator('.no-results');
        await expect(noResults).toBeVisible();
        await expect(noResults).toContainText('No flights found');
    });
});
