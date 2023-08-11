import 'package:flutter/material.dart';
import 'package:teleprompter/teleprompter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String text =
        '''Flutter package to create a teleprompter from a simple text
Features:
- Play the text generated in your app with an automatic scroll
- Record video directly inside the app
- Automatic save to gallery on stop recording
    
    The following text is just to make it easier to test the scrolling functionality:
    
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum sollicitudin elit id ex pellentesque, vitae blandit neque pulvinar. Aenean maximus ante nisi, ac lobortis erat euismod vitae. Etiam porttitor malesuada turpis, non lacinia diam tristique non. Nam pulvinar neque massa, sit amet gravida elit fringilla sit amet. Cras quis tristique diam. Cras commodo lacus at lorem fermentum, at aliquam eros facilisis. Morbi fringilla laoreet commodo. Sed placerat magna id arcu hendrerit, ac porttitor sapien porttitor. Phasellus mauris elit, condimentum ac iaculis ut, iaculis a urna. Morbi posuere sit amet diam ut auctor. Morbi sodales odio eleifend mauris venenatis ultricies. Aenean efficitur libero nec nulla fringilla, sit amet dignissim velit consectetur. Suspendisse consectetur porta arcu, sagittis dictum quam.

Nullam convallis tortor nisl, eget laoreet orci cursus at. Curabitur at luctus libero. Nunc nec orci et turpis tincidunt pretium. Curabitur nec dolor facilisis, molestie quam vitae, hendrerit elit. In a viverra ex. In hac habitasse platea dictumst. Curabitur luctus sapien sit amet pharetra varius. Fusce placerat lacus vel purus hendrerit, vel consectetur erat ornare. In eu nisi nunc.

Etiam ac euismod tortor, sit amet volutpat erat. Vestibulum non laoreet mauris. Quisque quis nibh at est semper gravida vel sit amet diam. Nullam convallis diam sed elit facilisis fringilla. Nunc in tincidunt tellus. Donec eleifend odio ligula, ut luctus arcu auctor eleifend. Sed lacinia et urna bibendum faucibus. Aenean varius tortor et tristique sollicitudin. Mauris eu volutpat nibh, sit amet maximus mauris. Duis ipsum dolor, malesuada maximus efficitur ut, cursus at justo. Maecenas sit amet iaculis orci.

Nunc commodo mauris a egestas ullamcorper. Nullam finibus rhoncus congue. Suspendisse in pellentesque erat. Nunc fermentum purus in lorem eleifend, et consequat diam ultrices. Nam ac mauris purus. Aliquam augue diam, mattis eget est sed, vulputate dictum nisl. Morbi vitae sapien ut justo consequat euismod et vehicula ante. Duis consectetur eros ac augue efficitur, ut suscipit lorem aliquet. Phasellus condimentum, augue in posuere luctus, mi erat ullamcorper ante, non ullamcorper arcu ligula eget libero. Suspendisse faucibus condimentum ex sed fermentum. Ut non ante iaculis, hendrerit tellus non, imperdiet sapien. Maecenas vestibulum ligula velit, sed venenatis nunc varius eu. Nam a elit sed dolor convallis rutrum at non dui. Etiam ultricies libero eros, ac porttitor odio mattis vel. Mauris posuere imperdiet lacus, vel dictum leo.

Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Etiam luctus pretium pellentesque. In nec tellus gravida ante maximus congue tempus non orci. Vivamus vel molestie sem. Nulla odio purus, condimentum et leo sagittis, semper tristique elit. Ut dui nisi, condimentum nec leo suscipit, fringilla sodales arcu. Nulla at suscipit augue, et feugiat diam. Nulla rhoncus augue a neque interdum venenatis. Praesent pellentesque lacus facilisis, bibendum metus at, dignissim sapien. Sed malesuada neque nulla, non egestas libero vulputate eu. Mauris a varius orci. Nullam euismod elit eu facilisis aliquam. Ut lectus mi, tincidunt at elit a, finibus feugiat ipsum. Integer vitae venenatis nisl. Mauris ac tristique ligula.''';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const HomeScreen(
        text: text,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String text;

  const HomeScreen({
    required this.text,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.text;
    textEditingController.selection =
        const TextSelection(baseOffset: 0, extentOffset: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teleprompter'),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "Text for teleprompter",
            ),
            scrollPadding: const EdgeInsets.all(20.0),
            keyboardType: TextInputType.multiline,
            maxLines: 99999,
            autofocus: true,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.play_arrow),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeleprompterWidget(
                text: textEditingController.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
