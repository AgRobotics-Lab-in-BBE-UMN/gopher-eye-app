import 'package:flutter/material.dart';
import 'package:gopher_eye/widgets/fields_feature/excel_screen.dart';
import 'package:gopher_eye/widgets/fields_feature/field_provider.dart';
import 'package:provider/provider.dart';

class FieldScreen extends StatefulWidget {
  const FieldScreen({super.key});

  @override
  State<FieldScreen> createState() => _FieldScreenState();
}

class _FieldScreenState extends State<FieldScreen> {
  @override
  Widget build(BuildContext context) {
    final fieldProvider = Provider.of<FieldProvider>(context);
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        toolbarHeight: 80,
        elevation: 3,
        title: const SafeArea(
          minimum: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: Text(
            "Fields",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExcelScreen()));
              },
              icon: const Icon(Icons.forward))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: fieldProvider.fields.length,
          itemBuilder: (context, index) {
            final field = fieldProvider.fields[index];
            return Column(
              children: [
                SelectableListItem(
                  item: field,
                  onChanged: (bool? value) {
                    fieldProvider.fieldSelection(index);
                  },
                  onEdit: () {
                    showEditItemDialog(context, field, index);
                  },
                  onDelete: () {
                    fieldProvider.removeField(index, field);
                  },
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addFeidDialogue(context);
        },
        backgroundColor: Colors.indigo,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  void addFeidDialogue(BuildContext context) {
    FieldType selectedFieldType = FieldType.Numeric;
    IconData selectedFieldIcon = Icons.star;
    TextEditingController fieldNameController = TextEditingController();
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: const Center(
                  child: Text("Add New Field"),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<FieldType>(
                      dropdownColor: Colors.grey[100],
                      value: selectedFieldType,
                      items: FieldType.values.map((FieldType value) {
                        return DropdownMenuItem<FieldType>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (FieldType? newValue) {
                        setState(() {
                          selectedFieldType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        DropdownButton<IconData>(
                            value: selectedFieldIcon,
                            items: <IconData>[
                              Icons.star,
                              Icons.ac_unit,
                              Icons.access_alarm,
                              Icons.accessibility,
                            ].map((IconData value) {
                              return DropdownMenuItem<IconData>(
                                value: value,
                                child: Icon(value),
                              );
                            }).toList(),
                            onChanged: (IconData? newIcon) {
                              setState(() {
                                selectedFieldIcon = newIcon!;
                              });
                            }),
                        Expanded(
                            child: TextFormField(
                          controller: fieldNameController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Enter Field Name"),
                        ))
                      ],
                    ),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            final newField = Field(fieldNameController.text,
                                selectedFieldIcon, false, selectedFieldType);
                            fieldProvider.addFields(newField);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Add",
                            style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w600),
                          ))
                    ],
                  )
                ],
              );
            },
          );
        });
  }

  void showEditItemDialog(BuildContext context, Field field, int index) {
    TextEditingController nameController =
        TextEditingController(text: field.fieldName);
    IconData selectedIcon = field.fieldIcon;
    FieldType selectedFieldType = field.fieldType;
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[100],
              title: const Center(child: Text('Edit Field')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<FieldType>(
                    value: selectedFieldType,
                    items: FieldType.values.map((FieldType value) {
                      return DropdownMenuItem<FieldType>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (FieldType? newValue) {
                      setState(() {
                        selectedFieldType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DropdownButton<IconData>(
                        value: selectedIcon,
                        items: <IconData>[
                          Icons.star,
                          Icons.ac_unit,
                          Icons.access_alarm,
                          Icons.accessibility,
                        ].map((IconData value) {
                          return DropdownMenuItem<IconData>(
                            value: value,
                            child: Icon(value),
                          );
                        }).toList(),
                        onChanged: (IconData? newValue) {
                          setState(() {
                            selectedIcon = newValue!;
                          });
                        },
                      ),
                      const SizedBox(width: 05.0),
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            labelText: 'Field Name',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final newField = Field(nameController.text,
                            selectedIcon, false, selectedFieldType);
                        fieldProvider.updateField(index, newField);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }
}

class SelectableListItem extends StatelessWidget {
  final Field item;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SelectableListItem({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.fieldIcon),
      title: Text(item.fieldName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: item.isSelected,
            onChanged: onChanged,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'edit':
                  onEdit();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
