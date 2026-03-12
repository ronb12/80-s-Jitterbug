"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import {
  listGalleryPhotos,
  addGalleryPhotoByUrl,
  updateGalleryPhoto,
  deleteGalleryPhoto,
  type GalleryPhoto,
} from "@/lib/gallery-service";
import { isAdminAuthenticated, setAdminAuthenticated, clearAdminSession, isAdminConfigured, validateAdminCredentials } from "@/lib/admin-auth";

export default function AdminGalleryPage() {
  const [authenticated, setAuthenticated] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordError, setPasswordError] = useState(false);

  useEffect(() => {
    if (isAdminAuthenticated()) setAuthenticated(true);
  }, []);

  const [photos, setPhotos] = useState<GalleryPhoto[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);
  const [newUrl, setNewUrl] = useState("");
  const [newCaption, setNewCaption] = useState("");
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editCaption, setEditCaption] = useState("");
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const handleUnlock = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateAdminCredentials(email, password)) {
      setAdminAuthenticated();
      setAuthenticated(true);
      setPasswordError(false);
    } else {
      setPasswordError(true);
    }
  };

  const loadPhotos = () => {
    setLoading(true);
    setError(null);
    listGalleryPhotos()
      .then(setPhotos)
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load gallery"))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    if (!authenticated) return;
    loadPhotos();
  }, [authenticated]);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    const url = newUrl.trim();
    if (!url) {
      setError("Enter an image URL.");
      return;
    }
    setAdding(true);
    setError(null);
    setSuccess(null);
    try {
      await addGalleryPhotoByUrl(url, newCaption, photos.length);
      setNewUrl("");
      setNewCaption("");
      loadPhotos();
      setSuccess("Photo added to the gallery.");
      setTimeout(() => setSuccess(null), 4000);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to add photo");
    } finally {
      setAdding(false);
    }
  };

  const handleStartEdit = (photo: GalleryPhoto) => {
    setEditingId(photo.id);
    setEditCaption(photo.caption);
  };

  const handleSaveCaption = async () => {
    if (!editingId) return;
    setError(null);
    try {
      await updateGalleryPhoto(editingId, { caption: editCaption });
      setPhotos((prev) =>
        prev.map((p) => (p.id === editingId ? { ...p, caption: editCaption } : p))
      );
      setEditingId(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Update failed");
    }
  };

  const handleDelete = async (photo: GalleryPhoto) => {
    setDeletingId(photo.id);
    setError(null);
    try {
      await deleteGalleryPhoto(photo.id);
      setPhotos((prev) => prev.filter((p) => p.id !== photo.id));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Delete failed");
    } finally {
      setDeletingId(null);
    }
  };

  if (!isAdminConfigured()) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-md rounded-2xl border border-amber-500/50 bg-black/50 p-8 text-center">
          <p className="text-amber-400">Admin not configured.</p>
          <Link href="/" className="mt-6 inline-block text-[var(--pink)] hover:underline">Back to site</Link>
        </div>
      </div>
    );
  }

  if (!authenticated) {
    return (
      <div className="min-h-screen px-4 py-24 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mx-auto max-w-sm rounded-2xl border border-[var(--pink)]/30 bg-black/50 p-8"
        >
          <h1 className="text-xl font-bold text-[var(--pink)]">Admin: Gallery</h1>
          <p className="mt-2 text-sm text-zinc-400">Sign in with your admin email and password.</p>
          <form onSubmit={handleUnlock} className="mt-6 space-y-4">
            <input
              type="email"
              value={email}
              onChange={(e) => { setEmail(e.target.value); setPasswordError(false); }}
              placeholder="Email"
              className="w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
              autoComplete="email"
            />
            <input
              type="password"
              value={password}
              onChange={(e) => { setPassword(e.target.value); setPasswordError(false); }}
              placeholder="Password"
              className="w-full rounded-lg border border-zinc-600 bg-black/50 px-4 py-3 text-white placeholder-zinc-500 focus:border-[var(--pink)] focus:outline-none"
              autoComplete="current-password"
            />
            {passwordError && <p className="text-sm text-[var(--pink)]">Incorrect email or password.</p>}
            <button type="submit" className="mt-4 w-full rounded-full bg-[var(--pink)] py-3 font-bold text-[var(--background)]">Unlock</button>
          </form>
          <Link href="/" className="mt-6 block text-center text-sm text-zinc-500 hover:text-white">← Back to site</Link>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen px-4 py-12 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-4xl">
        <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
          <h1 className="text-2xl font-bold text-[var(--pink)]">Gallery photos</h1>
          <div className="flex gap-3">
            <Link href="/admin/bookings" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Bookings</Link>
            <Link href="/admin/packages" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Packages</Link>
            <Link href="/admin/event-types" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">Event types</Link>
            <Link href="/gallery" target="_blank" rel="noopener noreferrer" className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-300 hover:bg-white/5">View gallery</Link>
            <button type="button" onClick={() => { clearAdminSession(); setAuthenticated(false); }} className="rounded-full border border-zinc-600 px-4 py-2 text-sm text-zinc-400 hover:text-white">Log out</button>
            <Link href="/" className="text-sm text-zinc-400 hover:text-white">← Back to site</Link>
          </div>
        </div>

        <p className="mb-6 text-sm text-zinc-400">
          Add photos by pasting a direct image URL (e.g. Imgur: right‑click image → Copy image address). No upgrade required—works on the free plan.
        </p>

        {error && <div className="mb-6 rounded-lg border border-[var(--pink)] bg-[var(--pink-muted)] p-4 text-[var(--pink)]">{error}</div>}
        {success && <div className="mb-6 rounded-lg border border-emerald-500/50 bg-emerald-500/10 p-4 text-emerald-400">{success}</div>}

        <motion.form
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          onSubmit={handleAdd}
          className="mb-10 rounded-xl border border-[var(--border)] bg-black/40 p-6"
        >
          <h2 className="mb-4 text-lg font-semibold text-white">Add photo by URL</h2>
          <div className="flex flex-wrap gap-4">
            <div className="flex-1 min-w-[200px]">
              <label className="block text-xs text-zinc-400 mb-1">Image URL *</label>
              <input
                type="url"
                value={newUrl}
                onChange={(e) => setNewUrl(e.target.value)}
                placeholder="https://… (e.g. Imgur: Copy image address)"
                className="w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white placeholder-zinc-500"
              />
            </div>
            <div className="flex-1 min-w-[200px]">
              <label className="block text-xs text-zinc-400 mb-1">Caption (optional)</label>
              <input
                type="text"
                value={newCaption}
                onChange={(e) => setNewCaption(e.target.value)}
                placeholder="e.g. Wedding at Riverside"
                className="w-full rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-white placeholder-zinc-500"
              />
            </div>
            <div className="flex items-end">
              <button
                type="submit"
                disabled={adding || !newUrl.trim()}
                className="rounded-full bg-[var(--pink)] px-6 py-2.5 text-sm font-semibold text-white hover:bg-[var(--pink-hover)] disabled:opacity-50"
              >
                {adding ? "Adding…" : "Add to gallery"}
              </button>
            </div>
          </div>
        </motion.form>

        {loading && <p className="text-zinc-400">Loading gallery…</p>}
        {!loading && photos.length === 0 && (
          <p className="text-zinc-500">No photos yet. Add one above to get started.</p>
        )}
        {!loading && photos.length > 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
          >
            {photos.map((photo) => (
              <div
                key={photo.id}
                className="rounded-xl border border-[var(--border)] bg-black/40 overflow-hidden"
              >
                <div className="aspect-square bg-zinc-900">
                  <img
                    src={photo.url}
                    alt={photo.caption || "Gallery"}
                    className="h-full w-full object-cover"
                  />
                </div>
                <div className="p-4">
                  {editingId === photo.id ? (
                    <div className="flex gap-2">
                      <input
                        type="text"
                        value={editCaption}
                        onChange={(e) => setEditCaption(e.target.value)}
                        className="flex-1 rounded-lg border border-zinc-600 bg-black/50 px-3 py-2 text-sm text-white"
                        placeholder="Caption"
                      />
                      <button type="button" onClick={handleSaveCaption} className="rounded-lg bg-[var(--pink)] px-3 py-2 text-sm font-medium text-white">Save</button>
                      <button type="button" onClick={() => setEditingId(null)} className="rounded-lg border border-zinc-600 px-3 py-2 text-sm text-zinc-400">Cancel</button>
                    </div>
                  ) : (
                    <>
                      <p className="text-sm text-zinc-300">{photo.caption || "—"}</p>
                      <div className="mt-2 flex gap-2">
                        <button type="button" onClick={() => handleStartEdit(photo)} className="text-xs text-zinc-500 hover:text-[var(--pink)]">Edit caption</button>
                        <button
                          type="button"
                          onClick={() => handleDelete(photo)}
                          disabled={deletingId === photo.id}
                          className="text-xs text-red-400 hover:text-red-300 disabled:opacity-50"
                        >
                          {deletingId === photo.id ? "Deleting…" : "Delete"}
                        </button>
                      </div>
                    </>
                  )}
                </div>
              </div>
            ))}
          </motion.div>
        )}
      </div>
    </div>
  );
}
