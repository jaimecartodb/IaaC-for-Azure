echo "Hola Mundo"

read -p "Usuario: " usuario
read -sp "Contraseña: " contrasena
echo
echo "Éxito!! Ya puedes entrar, $usuario"

echo "Creando un proyecto de consola para ti, $usuario..."
mkdir MiProyectoConsola
echo "print('Hola $usuario desde el proyecto de consola')" > proyectoConsola/app.py
echo "Proyecto creado con éxito. Ahora ejecuta 'python proyectoConsola/app.py' para asegurar que funciona."