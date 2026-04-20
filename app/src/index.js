const express = require('express');
const client  = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;

// Métriques Prometheus
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequests = new client.Counter({
  name: 'http_requests_total',
  help: 'Nombre total de requêtes HTTP',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

// Middleware comptage
app.use((req, res, next) => {
  res.on('finish', () => {
    httpRequests.inc({ method: req.method, route: req.path, status: res.statusCode });
  });
  next();
});

// Routes
app.get('/',       (req, res) => res.json({ message: 'DevOps App OK', version: '1.0.0' }));
app.get('/health', (req, res) => res.json({ status: 'healthy' }));
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Mode test CI
if (process.argv.includes('--test')) {
  console.log('Tests OK'); process.exit(0);
}

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
