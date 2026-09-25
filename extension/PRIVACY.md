# Privacy — GrokiPedia Citation Inspector prototype

The extension inspects links on the active page only after you select **Inspect this page**. It reads the links in the article, main area, or page body and uses their addresses and accessible labels to identify link hygiene signals. It returns counts and up to 20 displayed URL paths per category to the popup; displayed URLs omit query strings and fragments. It does not save or transmit page data, link data, browsing history, or results, and has no analytics or third-party recipients. Results are discarded when the popup closes. The extension requests only `activeTab` and `scripting` permissions. Chrome controls when temporary access expires.

The use of information received from Google APIs will adhere to the Chrome Web Store User Data Policy, including the Limited Use requirements.

This document describes the prototype at version 0.1.0. Recheck this statement and the Chrome Web Store privacy disclosures before publishing or adding any service, retention, or permissions.
