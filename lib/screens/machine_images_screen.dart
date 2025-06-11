import 'package:flutter/material.dart';

class MachineImagesScreen extends StatelessWidget {
  final List<MachineImage> machineImages = [
    MachineImage(
      name: 'アイムジャグラーEX',
      path: 'assets/img/im_juggler.gif',
    ),
    MachineImage(
      name: 'マイジャグラーⅤ',
      path: 'assets/img/my_juggler.gif',
    ),
    MachineImage(
      name: 'ゴーゴージャグラー3',
      path: 'assets/img/gogo_juggler.png',
    ),
    MachineImage(
      name: 'ファンキージャグラー2',
      path: 'assets/img/funky_juggler.png',
    ),
    MachineImage(
      name: 'ハッピージャグラーV Ⅲ',
      path: 'assets/img/happy_juggler.gif',
    ),
    MachineImage(
      name: 'ジャグラーガールズSS',
      path: 'assets/img/juggler_girls.jpg',
    ),
    MachineImage(
      name: 'ミスタージャグラー',
      path: 'assets/img/mister_juggler.jpg',
    ),
    MachineImage(
      name: 'ウルトラミラクルジャグラー',
      path: 'assets/img/ultramiracle_juggler.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('機種画像一覧'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 1 : 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: machineImages.length,
        itemBuilder: (context, index) {
          final machineImage = machineImages[index];

          return Card(
            elevation: 4,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    machineImage.name,
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageDetailScreen(
                              machineImage: machineImage,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        machineImage.path,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: ${machineImage.path}');
                          print('Error details: $error');
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                SizedBox(height: 8),
                                Text(
                                  '画像を読み込めません',
                                  style: TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final MachineImage machineImage;

  const ImageDetailScreen({
    Key? key,
    required this.machineImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(machineImage.name),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.asset(
            machineImage.path,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class MachineImage {
  final String name;
  final String path;

  MachineImage({
    required this.name,
    required this.path,
  });
}