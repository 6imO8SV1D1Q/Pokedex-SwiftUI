#!/usr/bin/env python3
"""
フォーム違いで性能が違うかチェック
"""
import requests
import time

# チェック対象
forms_to_check = [
    ('shellos', ['shellos', 'shellos-east', 'shellos-west']),
    ('gastrodon', ['gastrodon', 'gastrodon-east', 'gastrodon-west']),
    ('deerling', ['deerling-spring', 'deerling-summer', 'deerling-autumn', 'deerling-winter']),
    ('sawsbuck', ['sawsbuck-spring', 'sawsbuck-summer', 'sawsbuck-autumn', 'sawsbuck-winter']),
    ('frillish', ['frillish', 'frillish-male', 'frillish-female']),
    ('jellicent', ['jellicent', 'jellicent-male', 'jellicent-female']),
    ('pumpkaboo', ['pumpkaboo', 'pumpkaboo-small', 'pumpkaboo-large', 'pumpkaboo-super']),
    ('gourgeist', ['gourgeist', 'gourgeist-small', 'gourgeist-large', 'gourgeist-super']),
]

print("📋 フォーム違いの性能チェック\n")

for base_name, forms in forms_to_check:
    print(f"{'='*60}")
    print(f"【{base_name.upper()}】")
    
    stats_list = []
    abilities_list = []
    
    for form_name in forms:
        try:
            # shellos, gastrodonは-east/-westではなく別の名前かもしれない
            url = f"https://pokeapi.co/api/v2/pokemon/{form_name}/"
            response = requests.get(url)
            
            if response.status_code == 404:
                print(f"  ⚠️  {form_name}: 存在しません")
                time.sleep(0.1)
                continue
                
            response.raise_for_status()
            data = response.json()
            
            # 種族値
            stats = {stat['stat']['name']: stat['base_stat'] for stat in data.get('stats', [])}
            total = sum(stats.values())
            
            # 特性
            abilities = [a['ability']['name'] for a in data.get('abilities', [])]
            
            stats_list.append((form_name, stats, total))
            abilities_list.append((form_name, abilities))
            
            time.sleep(0.1)
            
        except Exception as e:
            print(f"  ❌ {form_name}: エラー - {e}")
            time.sleep(0.1)
    
    if len(stats_list) > 1:
        # 種族値比較
        first_stats = stats_list[0][1]
        first_total = stats_list[0][2]
        stats_differ = any(s[1] != first_stats or s[2] != first_total for s in stats_list[1:])
        
        # 特性比較
        first_abilities = set(abilities_list[0][1])
        abilities_differ = any(set(a[1]) != first_abilities for a in abilities_list[1:])
        
        print(f"\n  種族値: {'❌ 違う' if stats_differ else '✅ 同じ'}")
        print(f"  特性:   {'❌ 違う' if abilities_differ else '✅ 同じ'}")
        
        if stats_differ:
            print(f"\n  【種族値詳細】")
            for form_name, stats, total in stats_list:
                print(f"    {form_name}: 合計{total}")
                print(f"      HP:{stats.get('hp',0)} 攻:{stats.get('attack',0)} 防:{stats.get('defense',0)} 特攻:{stats.get('special-attack',0)} 特防:{stats.get('special-defense',0)} 素:{stats.get('speed',0)}")
        
        if abilities_differ:
            print(f"\n  【特性詳細】")
            for form_name, abilities in abilities_list:
                print(f"    {form_name}: {', '.join(abilities)}")
        
        print()

