"use client";

import { useEffect } from "react";
import { usePathname, useSearchParams } from "next/navigation";

declare global {
    interface Window {
        _paq: any[];
    }
}

interface MatomoTrackerProps {
    url?: string;
    siteId?: string;
}

export default function MatomoTracker({ url, siteId }: MatomoTrackerProps) {
    const pathname = usePathname();
    const searchParams = useSearchParams();

    useEffect(() => {
        if (!url || !siteId) return;

        // Initialize _paq if it doesn't exist
        const _paq = (window._paq = window._paq || []);

        // Check if script is already loaded
        if (document.getElementById("matomo-script")) {
            // Just track the page view if script is already there (client-side nav)
            _paq.push(["setCustomUrl", pathname + (searchParams?.toString() ? "?" + searchParams.toString() : "")]);
            _paq.push(["setDocumentTitle", document.title]);
            _paq.push(["trackPageView"]);
            return;
        }

        // Initial setup
        _paq.push(["trackPageView"]);
        _paq.push(["enableLinkTracking"]);

        // Script injection
        const u = url.endsWith("/") ? url : url + "/";
        _paq.push(["setTrackerUrl", u + "matomo.php"]);
        _paq.push(["setSiteId", siteId]);

        const d = document;
        const g = d.createElement("script");
        const s = d.getElementsByTagName("script")[0];
        g.id = "matomo-script";
        g.type = "text/javascript";
        g.async = true;
        g.src = u + "matomo.js";
        if (s && s.parentNode) {
            s.parentNode.insertBefore(g, s);
        }
    }, [url, siteId, pathname, searchParams]);

    return null;
}
