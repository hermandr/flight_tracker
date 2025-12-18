import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { Suspense } from "react";
import "./globals.css";
import MatomoTracker from "../components/MatomoTracker";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Flight Tracker",
  description: "Real-time flight tracking application",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable}`}>
        {children}
        <Suspense fallback={null}>
          <MatomoTracker
            url={process.env.NEXT_PUBLIC_MATOMO_URL}
            siteId={process.env.NEXT_PUBLIC_MATOMO_SITE_ID}
          />
        </Suspense>
      </body>
    </html>
  );
}
