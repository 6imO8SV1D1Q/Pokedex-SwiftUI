#!/usr/bin/env python3
"""
スカーレット・バイオレットに登場する全ポケモンのフォームを確認
"""
import json

with open('/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json', 'r') as f:
    data = json.load(f)

# 全国図鑑番号でグループ化
by_national = {}
for p in data['pokemon']:
    nat_num = p.get('nationalDexNumber')
    if nat_num:
        if nat_num not in by_national:
            by_national[nat_num] = []
        by_national[nat_num].append(p['name'])

print("📋 複数フォームが登録されているポケモン\n")

multi_form = {}
for nat_num, names in sorted(by_national.items()):
    if len(names) > 1:
        # バトルフォームや一時的な姿を除外
        filtered = [n for n in names if not any(x in n for x in [
            '-busted',  # ミミッキュ（化けの皮が剥がれた）
            '-cap',     # サトシのピカチュウ
            '-ash',     # サトシゲッコウガ
            '-totem',   # ぬしポケモン
            '-starter', # 相棒
        ])]
        
        if len(filtered) > 1:
            multi_form[nat_num] = filtered

for nat_num, names in multi_form.items():
    base_name = names[0]
    # 日本語名を取得
    base_pokemon = next((p for p in data['pokemon'] if p['name'] == base_name), None)
    name_ja = base_pokemon['nameJa'] if base_pokemon else ''
    
    print(f"#{nat_num:03d} {name_ja} ({base_name}): {len(names)}フォーム")
    for name in sorted(names):
        pokemon = next((p for p in data['pokemon'] if p['name'] == name), None)
        if pokemon:
            paldea = pokemon.get('pokedexNumbers', {}).get('paldea', '-')
            print(f"  ✅ {name} (パルデア#{paldea})")

print(f"\n合計: {len(multi_form)}種類のポケモンに複数フォーム登録済み")

# フォームが1つしか登録されていないが、実際には複数フォームがあるポケモンを確認
print("\n" + "="*60)
print("📋 フォームが不足している可能性のあるポケモン\n")

# 既知のフォーム違いポケモンリスト
known_forms = {
    201: ('unown', 'アンノーン', 28),  # A-Z + ! + ?
    386: ('deoxys', 'デオキシス', 4),  # ノーマル/アタック/ディフェンス/スピード
    412: ('burmy', 'ミノムッチ', 3),  # くさき/すなち/ゴミ
    413: ('wormadam', 'ミノマダム', 3),  # くさき/すなち/ゴミ
    422: ('shellos', 'カラナクシ', 2),  # にしのうみ/ひがしのうみ
    423: ('gastrodon', 'トリトドン', 2),  # にしのうみ/ひがしのうみ
    487: ('giratina', 'ギラティナ', 2),  # アナザー/オリジン
    492: ('shaymin', 'シェイミ', 2),  # ランド/スカイ
    585: ('deerling', 'シキジカ', 4),  # 春夏秋冬
    586: ('sawsbuck', 'メブキジカ', 4),  # 春夏秋冬
    592: ('frillish', 'プルリル', 2),  # オス/メス
    593: ('jellicent', 'ブルンゲル', 2),  # オス/メス
    641: ('tornadus', 'トルネロス', 2),  # けしん/れいじゅう
    642: ('thundurus', 'ボルトロス', 2),  # けしん/れいじゅう
    645: ('landorus', 'ランドロス', 2),  # けしん/れいじゅう
    647: ('keldeo', 'ケルディオ', 2),  # 通常/かくご
    648: ('meloetta', 'メロエッタ', 2),  # ボイス/ステップ
    649: ('genesect', 'ゲノセクト', 5),  # 通常+カセット4種
    666: ('vivillon', 'ビビヨン', 20),  # 模様違い
    669: ('flabebe', 'フラベベ', 5),  # 花の色
    670: ('floette', 'フラエッテ', 6),  # 花の色+エターナル
    671: ('florges', 'フラージェス', 5),  # 花の色
    676: ('furfrou', 'トリミアン', 10),  # カット違い
    678: ('meowstic', 'ニャオニクス', 2),  # オス/メス - 既に登録済み
    681: ('aegislash', 'ギルガルド', 2),  # シールド/ブレード
    710: ('pumpkaboo', 'バケッチャ', 4),  # サイズ違い
    711: ('gourgeist', 'パンプジン', 4),  # サイズ違い
    718: ('zygarde', 'ジガルデ', 3),  # 10%/50%/パーフェクト
    720: ('hoopa', 'フーパ', 2),  # いましめ/ときはなた
    741: ('oricorio', 'オドリドリ', 4),  # スタイル違い - 既に登録済み
    773: ('silvally', 'シルヴァディ', 18),  # タイプ違い
    774: ('minior', 'メテノ', 14),  # 色違い - 既に登録済み
    800: ('necrozma', 'ネクロズマ', 4),  # 通常/たそがれ/あかつき/ウルトラ
    801: ('magearna', 'マギアナ', 2),  # 通常/500年前
    888: ('zacian', 'ザシアン', 2),  # れきせん/けんのおう
    889: ('zamazenta', 'ザマゼンタ', 2),  # れきせん/たてのおう
    890: ('eternatus', 'ムゲンダイナ', 2),  # 通常/ムゲンダイマックス
    892: ('urshifu', 'ウーラオス', 2),  # いちげき/れんげき
    898: ('calyrex', 'バドレックス', 3),  # 通常/はくば/こくば
}

for nat_num, (base_name, name_ja, expected_forms) in known_forms.items():
    if nat_num in by_national:
        actual_forms = len(by_national[nat_num])
        if actual_forms < expected_forms:
            print(f"#{nat_num:03d} {name_ja} ({base_name})")
            print(f"  登録: {actual_forms}フォーム / 期待: {expected_forms}フォーム")
            print(f"  既存: {', '.join(by_national[nat_num])}")
            print()
    else:
        # このポケモンはSVに登場していない
        pass

