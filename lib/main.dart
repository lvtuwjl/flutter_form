import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Grid List';

    return const MaterialApp(
      title: title,
      home: MyForm(),
    );
  }
}

/// More examples see https://github.com/cfug/dio/blob/main/example
Future<dynamic> login(Map<String, dynamic> data) async {
  print("login request body: $data");
  final dio = Dio();
  final response = await dio.post('http://127.0.0.1:8084/login', data: data);
  print(response.data);
  return response.data;
}

/// More examples see https://github.com/cfug/dio/blob/main/example
Future<dynamic> getInfo(Map<String, dynamic> data) async {
  print("login request body: $data");
  final dio = Dio();
  final response = await dio.get('http://127.0.0.1:8084/info?userId=111');
  print(response.data);
  return response.data;
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true; // 控制密码是否隐藏

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APP Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Image.asset("images/lake.jpg"),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '用户名或邮箱',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                obscureText: _isObscure,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              // const SizedBox(height: 20),
              // 登录按钮
              Padding(
                padding: const EdgeInsets.only(top: 28.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          var resp = await _submitForm();
                          // print("object: resp: ${resp == null}");
                          // print("object: resp: ${resp is Map}");
                          assert(resp is Map);
                          if (resp == null) {
                            print("resp is null");
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return UserInfoPage(
                                data: resp,
                              );
                            }),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("登录"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              // //顺便提一下，设置圆角边框，可以使用Container的decoration功能
              // Container(
              //   width: 400,
              //   height: 200,
              //   //设置了 decoration 就不能设置color，两者只能存在一个
              //   decoration: BoxDecoration(
              //     border:
              //         // Border(left: BorderSide(width: 1, color: Colors.red)),
              //         Border.all(),
              //     borderRadius:
              //         const BorderRadius.only(topLeft: Radius.circular(2)),
              //   ),
              //   child: const Center(
              //     child: Text("Dart Flutter"),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 表单验证成功
      final String name = _nameController.text;
      final String password = _passwordController.text;
      // await Future.delayed(Duration(seconds: 2));
      // 构建请求参数
      final Map<String, dynamic> data = {'name': name, 'password': password};
      var resp = await getInfo(data);
      return resp;
    }
    return null;
  }
}

class UserInfoPage extends StatelessWidget {
  final Map? data;
  const UserInfoPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    var keys = data!['data'].keys.toList();
    print("info length: ${data!['data'].length}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Page 1"),
      ),
      // drawer: const Drawer(),
      body: Center(
        child: Container(
          // height: 200,
          child: GridView.builder(
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              var key = keys[index];
              var value = data!['data'][key];
              return Column(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text("$key"),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(1),
                        child: Text("$value"),
                      ),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 41,
                  // ),
                  Divider(
                    color: Colors.green.shade300,
                  ),
                ],
              );
            },
            itemCount: data!['data'].length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //每行三列
              childAspectRatio: 2.0, //显示区域宽高2:1
            ),
          ),
        ),
      ),
    );
  }
}
