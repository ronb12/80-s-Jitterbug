"use client";

import { useEffect } from "react";
import { app, analytics } from "@/lib/firebase";

export default function FirebaseInit() {
  useEffect(() => {
    // Firebase app and analytics are initialized when this module loads.
    // This component ensures the init runs in the client tree.
    if (analytics && app) {
      // Optional: log that analytics is ready (remove in production if desired)
      // console.log("Firebase Analytics ready");
    }
  }, []);

  return null;
}
