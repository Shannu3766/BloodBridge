import 'package:bloodbridge/providers/FiltersProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  final List<String> bloodgrouplist = [
    "A",
    "B",
    "O",
    "AB",
  ];
  final List<String> rhfactor = ["+", "-"];
  String? rh;
  String? bloodgroup;
  @override
  void initState() {
    rh = "+";
    bloodgroup = "O";
    // TODO: implement initState
    super.initState();
  }

  void ApplyFilter(String blood, String rh) {
    final bloodgroup = blood + rh;
    Fluttertoast.showToast(
      msg: "Filters Applied",
      gravity: ToastGravity.CENTER,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    ref.read(FiltersProvider.notifier).filterblood(bloodgroup, 0.toString());
    Navigator.pop(context);
  }

  void remove() {
    Fluttertoast.showToast(
      msg: "Filters cleared",
      gravity: ToastGravity.CENTER,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    setState(() {
      ref.read(FiltersProvider.notifier).clearFilter();
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select the Required Blood Group",
                style: TextStyle(fontSize: 30),
              ),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(label: Text("Blood Group")),
                      onChanged: ((value) {
                        setState(() {
                          bloodgroup = value!;
                        });
                        print(bloodgroup);
                      }),
                      value: bloodgroup,
                      items: bloodgrouplist
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return "select Bloodgrouop";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(label: Text("Rhesus")),
                      onChanged: ((value) {
                        setState(() {
                          rh = value!;
                        });
                      }),
                      value: rh,
                      items: rhfactor
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                      onPressed: () {
                        // ref.read(FiltersProvider.notifier).clearFilter();
                        remove();
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text("Remove Filter")),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ApplyFilter(bloodgroup!, rh!);
                    },
                    icon: const Icon(Icons.app_registration),
                    label: const Text("ApplyFilters"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
