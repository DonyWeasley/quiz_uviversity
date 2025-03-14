import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UniversityScreen extends StatefulWidget {
  @override
  _UniversityScreenState createState() => _UniversityScreenState();
}

class _UniversityScreenState extends State<UniversityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();

  void _addUniversity() {
    FirebaseFirestore.instance.collection('University').add({
      'name': _nameController.text,
      'country': _countryController.text,
      'rank': int.parse(_rankController.text),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("University added successfully!"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add university. Please try again."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    });

    _nameController.clear();
    _countryController.clear();
    _rankController.clear();
  }

  void _updateUniversity(String docId, String name, int rank) {
    FirebaseFirestore.instance.collection('University').doc(docId).update({
      'name': name,
      'rank': rank,
    });
  }

  void _deleteUniversity(String docId) {
    FirebaseFirestore.instance.collection('University').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "World University Rankings",
          style: TextStyle(
            fontSize: 22, // ขนาดที่พอเหมาะ
            fontWeight: FontWeight.bold,
            color: Colors.white, // สีตัวอักษรเป็นสีขาวเข้ม
            letterSpacing: 1.5, // ปรับระยะห่างของตัวอักษรให้เหมาะสม
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 5.0,
                color: Colors.black.withOpacity(0.4), // เงาที่นุ่มนวลขึ้น
              ),
            ],
          ),
        ),
        backgroundColor: Colors.blue.shade900, // พื้นหลังสีฟ้าเข้ม
        elevation: 12, // ความสูงที่มากขึ้นเพื่อเพิ่มความเด่น
        centerTitle: true, // ตั้งชื่อให้ตรงกลาง
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            _buildTextField(_nameController, 'University Name', Icons.school),
            _buildTextField(_countryController, 'Country', Icons.public),
            _buildTextField(_rankController, 'World Rank', Icons.star,
                isNumber: true),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addUniversity,
              icon: Icon(Icons.add, color: Colors.white), // ไอคอนสีขาว
              label: Text(
                'Add University',
                style: TextStyle(color: Colors.white), // ตัวอักษรสีขาว
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900, // พื้นหลังสีฟ้าเข้ม
                foregroundColor: Colors.white, // ตัวอักษรสีขาว
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // เพิ่มพื้นที่ด้านใน
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // ขอบมน
                ),
                elevation: 5, // ความสูงของปุ่มเพื่อเพิ่มมิติ
                shadowColor: Colors.black.withOpacity(0.3), // สีเงา
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('University')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  var universities = snapshot.data!.docs;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: universities.length,
                          itemBuilder: (context, index) {
                            var university = universities[index];
                            return _buildUniversityCard(university);
                          },
                        ),
                      ),
                      _buildFooter(universities.length),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUniversityCard(QueryDocumentSnapshot university) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          university['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Rank: ${university['rank']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showEditDialog(university),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteUniversity(university.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(QueryDocumentSnapshot university) {
    _nameController.text = university['name'];
    _rankController.text = university['rank'].toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Update University"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTextField(_nameController, 'University Name', Icons.school),
            _buildTextField(_rankController, 'World Rank', Icons.star,
                isNumber: true),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _updateUniversity(university.id, _nameController.text,
                  int.parse(_rankController.text));
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(int totalUniversities) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Divider(color: Colors.blueAccent, thickness: 1.2),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, color: Colors.blueAccent, size: 20), // 🎓 Icon
              SizedBox(width: 6),
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 800),
                child: Text(
                  "Total Universities: $totalUniversities",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87, // อ่านง่ายขึ้น
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
