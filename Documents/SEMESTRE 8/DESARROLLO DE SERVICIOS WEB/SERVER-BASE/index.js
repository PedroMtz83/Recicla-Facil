const express = require('express');
const port = 3003;
const morgan = require('morgan');

require('./utils/mongoConnection');

const app = express();
const booksRouter=require('./routers/books.routers');
const usersRouter=require('./routers/user.routers');

app.use(morgan('dev'));
app.use(express.json({limit:'50mb'}))

app.use('/books',booksRouter)
app.use('/users',usersRouter)

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
    });

app.get('/', (req, res) => {
    res.send('<h1>Welcome to the Book API</h1>');
});