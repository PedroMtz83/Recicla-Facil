const User = require('../models/user.model');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.registerUser = async (req, res) => {
    try{
        const { username, email, password } = req.body;
        console.log(req.body);

        const existingUser = await User.findOne({ email });
        if (existingUser){
            return res.status(400).json({
                error: "El usuario ya existe",
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({ username, email, password: hashedPassword});
        await newUser.save();

        return res.status(201).json({message: "Usuario registrado con éxito"});
    }catch (error){
        console.log(error);
        return res.status(500).json({ error: "Error al registrar el usuario" });
    }
};

exports.getUsers = async (req, res) => {
    try {
        const users = await User.find();
        return res.status(200).json(
            {
                message: 'Usuarios obtenidos con éxito',
                data: users
            }
        );
    } catch (error) {
        return res.status(500).json(
            {
                message: 'Error al consultar usuarios',
                data: error
            }
        );
    }
};

exports.loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        await User.findOne({ email })
            .then(async user => {
                if (!user) {
                    return res.status(401).json({ error: 'Credenciales inválidas' });
                }

                const passwordMatch = await bcrypt.compare(password, user.password);
                if (!passwordMatch) {
                    return res.status(401).json({ error: 'Credenciales inválidas' });
                }

                const token = jwt.sign({ userId: user._id, userName: user.username }, 
                    'secreto', { expiresIn: '8h' });

                let formatUser = {
                    _id: user._id,
                    userName: user.username,
                    userEmail: user.email
                };

                return res.json({
                    user: formatUser,
                    token: token,
                    action: 'login'
                });
            }).catch(err => {
                return res.status(500).json(
                    {
                        action: 'login',
                        error: error
                    }
                );
            });
    } catch (error) {
        res.status(500).json({ error: 'Error al iniciar sesión' });
    }
};