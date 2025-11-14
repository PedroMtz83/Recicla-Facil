import 'package:flutter/material.dart';

import '../models/punto_reciclaje.dart';
import '../services/puntos_reciclaje_service.dart';
import '../services/solicitudes_puntos_service.dart';
// Widget para el diálogo de edición. Es un StatefulWidget para manejar los controladores.
class DialogoEditarPunto extends StatefulWidget {
  final PuntoReciclaje punto;
  final VoidCallback onPuntoActualizado; // Función para notificar la actualización

  const DialogoEditarPunto({
    super.key,
    required this.punto,
    required this.onPuntoActualizado,
  });

  @override
  State<DialogoEditarPunto> createState() => _DialogoEditarPuntoState();
}

class _DialogoEditarPuntoState extends State<DialogoEditarPunto> {
  // Clave para identificar y validar nuestro formulario.
  final _formKey = GlobalKey<FormState>();
  final SolicitudesPuntosService _solicitudesService = SolicitudesPuntosService();

  // Usar la lista del servicio para mantener consistencia
  List<String> get _tiposMaterial => _solicitudesService.tiposMaterialDisponibles
      .where((material) => material != 'Todos') // Excluir "Todos" ya que es para filtros
      .toList();
  List<String> _tiposSeleccionados = [];
  // Controladores para cada campo del formulario.
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _telefonoController;
  late TextEditingController _horarioController;

  bool _estaCargando = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos actuales del punto.
    _nombreController = TextEditingController(text: widget.punto.nombre);
    _descripcionController = TextEditingController(text: widget.punto.descripcion);
    // Unimos la lista de materiales en un solo string para el campo de texto.
    _tiposSeleccionados = List<String>.from(widget.punto.tipoMaterial);    _telefonoController = TextEditingController(text: widget.punto.telefono);
    _horarioController = TextEditingController(text: widget.punto.horario);
  }

  @override
  void dispose() {
    // Es importante desechar los controladores para liberar memoria.
    _nombreController.dispose();
    _descripcionController.dispose();
    _telefonoController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  // Función que se llama al presionar "Actualizar".
  Future<void> _submitForm() async {
    final esFormularioValido = _formKey.currentState?.validate() ?? false;
    final sonMaterialesValidos = _tiposSeleccionados.isNotEmpty;

    if (esFormularioValido && sonMaterialesValidos) {
      setState(() => _estaCargando = true);

      // --- 4. USAMOS DIRECTAMENTE la lista _tiposSeleccionados ---
      // Ya no es necesario procesar un string.
      final bool exito = await PuntosReciclajeService.actualizarPuntoReciclaje(
        puntoId: widget.punto.id,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        tipo_material: _tiposSeleccionados, // <-- Cambio clave
        telefono: _telefonoController.text,
        horario: _horarioController.text,
      );

      setState(() => _estaCargando = false);

      if (exito && mounted) {
        Navigator.of(context).pop();
        widget.onPuntoActualizado();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo actualizar el punto.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (!sonMaterialesValidos) {
      // Si el formulario es válido pero no los materiales, forzamos una reconstrucción
      // para que se muestre el mensaje de error del selector de materiales.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Punto de Reciclaje'),
      // Usamos SingleChildScrollView para evitar desbordamiento si el teclado aparece.
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
                validator: (value) => (value?.isEmpty ?? true) ? 'Este campo es obligatorio' : null,
              ),
              SizedBox(height: 16),
              _buildMaterialSelector(),
              SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) => (value?.isEmpty ?? true) ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _horarioController,
                decoration: const InputDecoration(labelText: 'Horario'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Este campo es obligatorio' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _estaCargando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        // El botón de "Actualizar" muestra un indicador de carga si está procesando.
        ElevatedButton(
          onPressed: _estaCargando ? null : _submitForm,
          child: _estaCargando
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Text('Actualizar'),
        ),
      ],
    );
  }

  Widget _buildMaterialSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materiales que se reciclan *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Selecciona todos los materiales que acepta este punto:',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tiposMaterial.map((material) {
            return FilterChip(
              label: Text(material),
              selected: _tiposSeleccionados.contains(material),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _tiposSeleccionados.add(material);
                  } else {
                    _tiposSeleccionados.remove(material);
                  }
                });
              },
              selectedColor: Colors.green[100],
              checkmarkColor: Colors.green,
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
        if (_tiposSeleccionados.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Selecciona al menos un tipo de material',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
