const express=require('express');
const app=express();
const port=3000;
const conectarDB=require('./config/db');
const router=require('./routes/router');

conectarDB();

app.use(express.json());

app.get('/', (req, res) => {
  res.send('¡Servidor Node.js funcionando correctamente!');
});

app.use('/api', router);

app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});