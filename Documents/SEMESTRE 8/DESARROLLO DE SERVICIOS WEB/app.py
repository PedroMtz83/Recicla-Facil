import graphene

# Definimos un tipo de objeto para representar un autor
class Autor(graphene.ObjectType):
    id = graphene.Int()
    nombre = graphene.String()

# Definimos un tipo de objeto para representar un libro
class Libro(graphene.ObjectType):
    id = graphene.Int()
    titulo = graphene.String()
    autor = graphene.Field(Autor)

# Definimos la consulta raíz
class Query(graphene.ObjectType):
    # Campo para obtener un libro por su ID
    libro = graphene.Field(Libro, id=graphene.Int())

    # Campo para obtener todos los libros
    libros = graphene.List(Libro)

    def resolve_libro(self, info, id):
        # Aquí iría la lógica para obtener el libro de una base de datos, etc.
        # Por simplicidad, vamos a simular datos
        if id == 1:
            return Libro(id=1, titulo="El Señor de los Anillos", autor=Autor(id=1, nombre="J.R.R. Tolkien"))
        return None

    def resolve_libros(self, info):
        # Aquí iría la lógica para obtener todos los libros de una base de datos, etc.
        # Por simplicidad, vamos a simular datos
        return [
            Libro(id=1, titulo="El Señor de los Anillos", autor=Autor(id=1, nombre="J.R.R. Tolkien")),
            Libro(id=2, titulo="1984", autor=Autor(id=2, nombre="George Orwell")),
        ]

# Creamos el esquema de GraphQL
schema = graphene.Schema(query=Query)

# Ejemplo de consulta
query = """
    query {
        libro(id: 1) {
            id
            titulo
            autor {
                nombre
            }
        }
        libros {
            id
            titulo
        }
    }
"""

# Ejecutamos la consulta
result = schema.execute(query)

# Imprimimos el resultado
print(result.data)