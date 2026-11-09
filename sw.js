// Service worker do Bolso Feliz: permite instalar o app e abrir a tela mesmo com internet ruim.
// Os dados (Supabase) nunca são guardados aqui: só os arquivos do próprio app.
const CACHE = "bolso-feliz-v1";
const ARQUIVOS = [
  "./", "./index.html", "./config.js", "./manifest.webmanifest",
  "./icons/icon-192.png", "./icons/icon-512.png", "./icons/apple-touch-icon.png", "./icons/favicon-32.png"
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ARQUIVOS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((nomes) => Promise.all(nomes.filter((n) => n !== CACHE).map((n) => caches.delete(n))))
      .then(() => self.clients.claim())
  );
});

// Arquivos do app: tenta a internet primeiro (para sempre pegar a versão nova) e usa a cópia se estiver offline.
self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;
  e.respondWith(
    fetch(req)
      .then((resp) => {
        if (resp.ok) { const copia = resp.clone(); caches.open(CACHE).then((c) => c.put(req, copia)); }
        return resp;
      })
      .catch(() => caches.match(req).then((r) => r || caches.match("./index.html")))
  );
});
