import 'package:selam/data/repositories/auth.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:selam/logic/auth_bloc/auth_bloc.dart';
import 'package:selam/presentation/screens/home/home_page.dart';
import 'package:selam/presentation/widgets/buttons/rectangular_button.dart';
import 'package:selam/presentation/widgets/form/form_field.dart';
import 'package:selam/presentation/widgets/form/input_decoration.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:selam/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UpdateInfo extends StatefulWidget {
  const UpdateInfo({super.key, required this.user});

  final MyUser user;

  @override
  State<UpdateInfo> createState() => _UpdateInfoState();
}

class _UpdateInfoState extends State<UpdateInfo> {
  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String firstName = "";
  String lastName = "";
  String gender = "";
  DateTime? selectedDOB;
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.name.split(" ").first;
    _lastNameController.text = widget.user.name.split(" ").length > 1
        ? widget.user.name.split(" ").last
        : "";
    selectedDOB = widget.user.dob;
    gender = widget.user.gender?.isNotEmpty == true ? widget.user.gender! : "";
    context.read<AuthBloc>().add(CheckAuth());
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime(2006),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.pink.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey.shade900,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDOB = picked);
    }
  }

  Future<void> updateInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      String age = _calculateAge(selectedDOB!).toString();
      await userRepository.updateName("$firstName $lastName", widget.user.id);
      await userRepository.updateDOB(selectedDOB!, widget.user.id);
      await userRepository.updateGender(gender, widget.user.id);
      await userRepository.updateAge(age, widget.user.id);
      MyUser updatedUser = await authRepository.getMyUser(widget.user.id);
      setState(() => isLoading = false);
      if (updatedUser.name.isNotEmpty &&
          updatedUser.dob != null &&
          updatedUser.gender != null &&
          updatedUser.age != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to update profile")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade600, Colors.red.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(FontAwesomeIcons.heart,
                            size: 50, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          "Love is in the air! 💕",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Complete your profile to find your perfect match! ❤️",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  buildFormField(
                    label: 'First Name',
                    field: TextFormField(
                      controller: _firstNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        hintText: 'Enter your first name',
                        icon: FontAwesomeIcons.solidUser,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'First name is required' : null,
                      onChanged: (value) => setState(() => firstName = value),
                    ),
                  ),
                  buildFormField(
                    label: 'Last Name',
                    field: TextFormField(
                      controller: _lastNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        hintText: 'Enter your last name',
                        icon: FontAwesomeIcons.solidUser,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Last name is required' : null,
                      onChanged: (value) => setState(() => lastName = value),
                    ),
                  ),
                  buildFormField(
                    label: 'Date of Birth',
                    field: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          initialValue: selectedDOB != null
                              ? "${selectedDOB!.year}/${selectedDOB!.month}/${selectedDOB!.day}"
                              : "",
                          style: TextStyle(color: Colors.white),
                          validator: (value) =>
                              selectedDOB == null ? 'Select your DOB' : null,
                          decoration: inputDecoration(
                            hintText: selectedDOB == null
                                ? 'Select your date of birth'
                                : '${selectedDOB!.day}/${selectedDOB!.month}/${selectedDOB!.year}',
                            icon: FontAwesomeIcons.cakeCandles,
                          ),
                        ),
                      ),
                    ),
                  ),
                  buildFormField(
                    label: 'Gender',
                    field: DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[850],
                      value: gender.isNotEmpty ? gender : null,
                      items: ['Male', 'Female']
                          .map((gender) => DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender,
                                    style: TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => gender = value!),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Select gender'
                          : null,
                      decoration: inputDecoration(
                        hintText: 'Select your gender',
                        icon: FontAwesomeIcons.venusMars,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  rectangularButton(
                      context,
                      isLoading
                          ? buildLoadingIndicator(24, Colors.white)
                          : Text("Update Info 💖",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                      () => updateInfo()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
