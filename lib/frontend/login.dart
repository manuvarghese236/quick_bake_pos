import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:windowspos/api/api.dart';
import 'package:windowspos/frontend/dashboard.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  @override
  String code = '';
  String username = '';
  String password = '';
  bool _securePassword = true;

  //load variable
  bool load = false;

  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  //function to hide and show password
  showHide() {
    setState(() {
      _securePassword = !_securePassword;
    });
  }

  //widget to show icons
  Widget iconDisplay(bool data) {
    if (data) {
      return Icon(
        Icons.visibility_off,
        size: 14,
        color: Color.fromRGBO(181, 184, 203, 1),
      );
    } else {
      return Icon(
        Icons.visibility,
        size: 14,
        color: Color.fromRGBO(181, 184, 203, 1),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: load
          ? Container(
              child: Center(
                  child: CircularProgressIndicator(
                strokeWidth: 1,
                color: Colors.red,
              )),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 0, bottom: 5),
                    width: MediaQuery.of(context).size.width / 1.15,
                    // color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/pay.png'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: Container(
                    // color: Colors.yellow,
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        // padding: EdgeInsets.a,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10, bottom: 10),
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "USERNAME",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: API.textcolor),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 20, right: 20),
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: TextFormField(
                                  cursorColor: Colors.green,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  style: TextStyle(color: Colors.grey),
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          Color.fromRGBO(248, 248, 253, 1),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.green,
                                          width: 1.0,
                                        ),
                                      ),
                                      hintStyle: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color:
                                              Color.fromRGBO(181, 184, 203, 1),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                      contentPadding: EdgeInsets.fromLTRB(
                                          20.0, 15.0, 20.0, 15.0),
                                      hintText: "Enter Username",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0))),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter Username";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() => username = (val));
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10, bottom: 10),
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "PASSWORD",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: API.textcolor),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 20, right: 20),
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: TextFormField(
                                  cursorColor: Colors.green,
                                  style: TextStyle(color: Colors.grey),
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          Color.fromRGBO(248, 248, 253, 1),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.green,
                                          width: 1.0,
                                        ),
                                      ),
                                      hintStyle: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color:
                                              Color.fromRGBO(181, 184, 203, 1),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                      contentPadding: EdgeInsets.fromLTRB(
                                          20.0, 15.0, 20.0, 15.0),
                                      suffixIcon: IconButton(
                                        onPressed: showHide,
                                        icon: iconDisplay(_securePassword),
                                      ),
                                      hintText: "Enter Password",
                                      // hintText: 'demo',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0))),
                                  validator: (val) =>
                                      val!.length < 3 ? 'Enter Password' : null,
                                  obscureText: _securePassword,
                                  onChanged: (val) {
                                    setState(() => password = (val));
                                  },
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height / 8,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              print(
                                                  "------------------------- LOGIN BUTTON --------------------------");
                                              setState(() {
                                                load = true;
                                              });
                                              final dynamic userloginresponse =
                                                  //"DEHNEE"
                                                  await API.loginAPI("STAGING",
                                                      username, password);
                                              if (userloginresponse['status'] ==
                                                  'success') {
                                                final dynamic prefresult = await API.addPrefferenceUserDetails(
                                                    userloginresponse['data']
                                                        ['user_id'],
                                                    userloginresponse['data']
                                                        ['name'],
                                                    userloginresponse['data']
                                                        ['_token'],
                                                    userloginresponse["data"]
                                                        ["company_name"],
                                                    userloginresponse["data"]
                                                        ["billing_address"],
                                                    userloginresponse["data"]
                                                        ["genral_phno"],
                                                    userloginresponse["data"]
                                                        ["default_customer_id"],
                                                    userloginresponse["data"]
                                                        ["trn_no"],
                                                    API.imgurl +
                                                        userloginresponse[
                                                                "data"]
                                                            ["company_logo"],
                                                    userloginresponse["data"]
                                                            ["warehouse_id"]
                                                        .toString(),
                                                    userloginresponse['data'][
                                                            'master_company_id']
                                                        .toString(),
                                                    userloginresponse['data']
                                                            ['barcodenabled']
                                                        .toString());
                                                if (prefresult['status'] ==
                                                    'success') {
                                                  print("Manu---- test");
                                                  pushWidgetWhileRemove(
                                                      newPage:
                                                          const dashboard(),
                                                      context: context);
                                                  Get.snackbar("Success",
                                                      'User Authenticated',
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                      backgroundColor:
                                                          Colors.green,
                                                      colorText: Colors.white);
                                                } else {
                                                  setState(() {
                                                    load = false;
                                                  });
                                                  Get.snackbar("Failed",
                                                      "User cache miss",
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.white);
                                                }
                                              } else {
                                                setState(() {
                                                  load = false;
                                                });
                                                Get.snackbar("Failed",
                                                    'User Authentication Failed',
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4,
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white);
                                              }
                                            } else {
                                              Get.snackbar("Failed",
                                                  'Please Fill Correct Details',
                                                  backgroundColor: Colors.red,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          4,
                                                  colorText: Colors.white);
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: API.tilecolor,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            margin: const EdgeInsets.only(
                                                left: 20, right: 20),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.5,
                                            height: 48,
                                            child: Center(
                                              child: Text(
                                                "LOGIN",
                                                style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            ),
    );
  }
}
