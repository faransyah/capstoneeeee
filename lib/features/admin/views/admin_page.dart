import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// BENAR
import '../../add_user/views/add_user_page.dart';



// --- HELPER UNTUK BASE URL ---

String getBaseUrl() {

  if (kIsWeb) return "http://127.0.0.1:8000";

  if (Platform.isAndroid) return "http://10.0.2.2:8000";

  return "http://127.0.0.1:8000";

}



// --- MODEL USER ---

class User {

  final String id;

  final String name;

  final String role;



  User({required this.id, required this.name, required this.role});



  factory User.fromJson(Map<String, dynamic> json) {

    return User(

      id: json['id'].toString(),

      name: json['name'],

      role: json['role'],

    );

  }

}



class AdminPage extends StatefulWidget {

  const AdminPage({super.key});



  @override

  State<AdminPage> createState() => _AdminPageState();

}



class _AdminPageState extends State<AdminPage> {

  final TextEditingController _searchController = TextEditingController();

  List<User> _allUsers = [];

  List<User> _filteredUsers = [];



  bool _isLoading = true;

  String? _errorMessage;



  @override

  void initState() {

    super.initState();

    _searchController.addListener(_filterUsers);

    _fetchUsersFromDatabase();

  }



  @override

  void dispose() {

    _searchController.removeListener(_filterUsers);

    _searchController.dispose();

    super.dispose();

  }



  // --- FETCH DATA USERS DENGAN TOKEN ---

  Future<void> _fetchUsersFromDatabase() async {

    setState(() {

      _isLoading = true;

      _errorMessage = null;

    });



    try {

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('auth_token');



      if (token == null) {

        setState(() {

          _errorMessage = "Token tidak ditemukan. Silakan login ulang.";

          _isLoading = false;

        });

        return;

      }



      final response = await http.get(

        Uri.parse('${getBaseUrl()}/api/users'),

        headers: {

          'Authorization': 'Bearer $token',

          'Accept': 'application/json',

        },

      );



      if (response.statusCode == 200) {

        List<dynamic> responseData = json.decode(response.body)['data'];

        List<User> users = responseData.map((json) => User.fromJson(json)).toList();

        setState(() {

          _allUsers = users;

          _filteredUsers = users;

          _isLoading = false;

        });

      } else {

        setState(() {

          _errorMessage =

              "Gagal memuat data. Server merespon: ${response.statusCode}. Cek token atau hak akses Anda.";

          _isLoading = false;

        });

      }

    } catch (e) {

      setState(() {

        _errorMessage = "Terjadi kesalahan koneksi: ${e.toString()}";

        _isLoading = false;

      });

    }

  }



  void _filterUsers() {

    String query = _searchController.text.toLowerCase();

    setState(() {

      _filteredUsers = _allUsers.where((user) {

        return user.name.toLowerCase().contains(query);

      }).toList();

    });

  }



  Widget _buildBodyContent() {

    if (_isLoading) {

      return const Center(child: CircularProgressIndicator());

    }



    if (_errorMessage != null) {

      return Center(

        child: Padding(

          padding: const EdgeInsets.all(20.0),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Text(

                'Oops! Terjadi kesalahan',

                style: Theme.of(context).textTheme.titleLarge,

                textAlign: TextAlign.center,

              ),

              const SizedBox(height: 10),

              Text(

                _errorMessage!,

                style: TextStyle(color: Colors.grey[700]),

                textAlign: TextAlign.center,

              ),

              const SizedBox(height: 20),

              ElevatedButton(

                onPressed: _fetchUsersFromDatabase,

                child: const Text('Coba Lagi'),

              )

            ],

          ),

        ),

      );

    }



    return Padding(

      padding: const EdgeInsets.all(16.0),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          TextField(

            controller: _searchController,

            decoration: InputDecoration(

              hintText: 'Cari user berdasarkan nama...',

              prefixIcon: const Icon(Icons.search),

              border: OutlineInputBorder(

                borderRadius: BorderRadius.circular(12.0),

              ),

              filled: true,

              fillColor: Colors.grey[100],

            ),

          ),

          const SizedBox(height: 20),

          Text(

            "Daftar User (${_filteredUsers.length})",

            style: Theme.of(context).textTheme.titleLarge?.copyWith(

                  fontWeight: FontWeight.bold,

                ),

          ),

          const SizedBox(height: 10),

          Expanded(

            child: _filteredUsers.isEmpty

                ? Center(

                    child: Text(

                      _searchController.text.isEmpty

                          ? 'Belum ada data user.'

                          : 'User tidak ditemukan.',

                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),

                    ),

                  )

                : ListView.builder(

                    itemCount: _filteredUsers.length,

                    itemBuilder: (context, index) {

                      final user = _filteredUsers[index];

                      return Card(

                        margin: const EdgeInsets.symmetric(vertical: 6.0),

                        elevation: 2.0,

                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(10.0),

                        ),

                        child: ListTile(

                          contentPadding: const EdgeInsets.symmetric(

                              horizontal: 16.0, vertical: 8.0),

                          title: Text(

                            user.name,

                            style: const TextStyle(fontWeight: FontWeight.bold),

                          ),

                          subtitle: Text(user.role),

                          trailing: Row(

                            mainAxisSize: MainAxisSize.min,

                            children: [

                              Tooltip(

                                message: 'Edit User',

                                child: IconButton(

                                  icon: const Icon(Icons.edit_outlined),

                                  color: Colors.blue.shade700,

                                  onPressed: () {},

                                ),

                              ),

                              Tooltip(

                                message: 'Hapus User',

                                child: IconButton(

                                  icon: const Icon(Icons.delete_outline),

                                  color: Colors.red.shade700,

                                  onPressed: () {},

                                ),

                              ),

                            ],

                          ),

                        ),

                      );

                    },

                  ),

          ),

        ],

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Admin Dashboard"),

      ),

      body: _buildBodyContent(),

      floatingActionButton: FloatingActionButton(

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(builder: (context) => const AddUserPage()),

          );

        },

        tooltip: 'Tambah User Baru',

        child: const Icon(Icons.add),

      ),

    );

  }

}