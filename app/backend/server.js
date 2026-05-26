const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Simulated database connection check
const dbUri = process.env.DATABASE_URL || "mongodb://localhost:27017/devopsdb";

app.get('/api/health', (req, res) => {
    res.status(200).json({ 
        status: "UP", 
        backend: "Node.js", 
        database: "Connected (Simulated)" 
    });
});

app.get('/api/items', (req, res) => {
    res.json([
        { id: 1, name: "CI/CD Pipeline Automated" },
        { id: 2, name: "Infrastructure Provisioned via Terraform" },
        { id: 3, name: "Monitored via Prometheus & Grafana" }
    ]);
});

app.listen(PORT, () => {
    console.log(`Backend server running on port ${PORT}`);
});
