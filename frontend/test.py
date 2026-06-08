import sys

with open(r'c:\Users\Utente\Documents\Progetti\Qi_App\qi-app\frontend\lib\presentation\pages\home_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('''            onTap: (index) {
              ref.read(bottomNavIndexProvider.notifier).setIndex(index);
            },''', '''            onTap: (index) {
              if (index == 0) {
                setState(() {
                  _homeDataFuture = HomeApi().fetchHomeData();
                });
              }
              ref.read(bottomNavIndexProvider.notifier).setIndex(index);
            },''')

with open(r'c:\Users\Utente\Documents\Progetti\Qi_App\qi-app\frontend\lib\presentation\pages\home_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)
