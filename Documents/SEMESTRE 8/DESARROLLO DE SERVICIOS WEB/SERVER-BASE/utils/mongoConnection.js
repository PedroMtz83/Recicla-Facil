const mongoose = require('mongoose');

mongoose.connect('mongodb+srv://jolumartinezro:bnkGBX4djEomc2eM@books.uj0uxtb.mongodb.net/?retryWrites=true&w=majority&appName=books')
.then(() => {console.log('MongoDB connected successfully');})
.catch((err) => {console.log('MongoDB connection error:', err);});

module.exports= mongoose;
