import 'package:flutter/material.dart';


import './statistic_page.dart';


class Statistic_page extends StatelessWidget {

  Widget statisticpage(BuildContext context, String name, String path) {

    return Column(children: [

      Row(

        children: [

          const SizedBox(width: 10),

          const Icon(Icons.bar_chart, size: 50),

          const SizedBox(width: 20),

          Expanded(

            child: Text(

              name,

              style: const TextStyle(fontSize: 20),

              overflow: TextOverflow.ellipsis,

            ),

          ),

          const SizedBox(width: 10),

          IconButton(

            icon: const Icon(Icons.search, size: 30),

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                    builder: (_) => StatisticPage(

                          imageName: name,

                          imagePath: path,

                        )),

              );

            },

          ),

          const SizedBox(width: 10)

        ],

      ),

      const SizedBox(height: 15),

      Container(

        height: 1,

        decoration: const BoxDecoration(

          border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),

        ),

      ),

      const SizedBox(height: 30)

    ]);

  }


  Widget build(BuildContext context) {

    List<Widget> statistic_list = [

      statisticpage(context, "Distribution of Grouped Discolouration Colour Descriptions",

          "assets/Statistic_example_1.png"),

      statisticpage(context, "Water Outfall Characteristics - 'Yes' Counts",

          "assets/Statistic_example_2.png"),

      statisticpage(

          context, "Water Quality Indicators - 'Yes' Counts", "assets/Statistic_example_3.png"),

      statisticpage(context, "Wildlife_Observation", "assets/Statistic_example_4.png"),

    ];


    return MaterialApp(

      home: Scaffold(

          appBar: AppBar(

            backgroundColor: const Color.fromARGB(255, 53, 58, 83),

            title: const Text(

              'Statistics',

              style: const TextStyle(color: Colors.white),

            ),

          ),

          body: Column(

            children: [

              const SizedBox(height: 30),

              Expanded(

                child: ListView(

                  children: statistic_list,

                ),

              )

            ],

          )),

    );

  }

}

