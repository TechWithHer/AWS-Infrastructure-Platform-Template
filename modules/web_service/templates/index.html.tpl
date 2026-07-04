<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>${service} — ${environment}</title>
  <style>
    body { font-family: system-ui, sans-serif; background:#0f172a; color:#e2e8f0;
           display:flex; align-items:center; justify-content:center; height:100vh; margin:0; }
    .card { text-align:center; padding:2.5rem 3rem; border:1px solid #334155;
            border-radius:14px; background:#1e293b; }
    h1 { margin:0 0 .25rem; }
    .env { display:inline-block; padding:.2rem .7rem; border-radius:999px;
           background:#7c3aed; font-size:.8rem; letter-spacing:.05em; }
    code { color:#38bdf8; }
  </style>
</head>
<body>
  <div class="card">
    <span class="env">${environment}</span>
    <h1>${service}</h1>
    <p>Instance: <code>${instance}</code></p>
    <p>Served on host port <code>${host_port}</code></p>
    <p>Provisioned with Terraform.</p>
  </div>
</body>
</html>
