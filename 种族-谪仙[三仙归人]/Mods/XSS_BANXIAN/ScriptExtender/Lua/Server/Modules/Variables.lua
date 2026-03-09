local Variables = {}

-- 常量
Variables.Constants = {
    Hostile = {},
    Filter = {
        Status = {
            IsSpecialID = {
                'TECHNICAL',
                'INSURFACE',
                'LEGENDARYACTION',
                'DEBUG',
                'TOGGLE',
                'VFX',
                'HELPER',
                'HARD',
                'POLTERGEIST_EASY',
                'HARDCORE',
                'TUT_',
                'ATTACK_',
                'BANXIAN',
                'BanXian',
                'CuiTi',
                'FABAO',
                'CUITI',
                'Shout_',
                'SHOUT_',
                'SIGNAL',
                'DYING',
                'DT_',
                'DR_',
                'FSZMG',
                'STEELWATCHER_QUADRUPED_SELFDESTRUCT_BEGIN', --钢铁卫士自爆
                'STEELWATCHER_BIPED_SELFDESTRUCT_BEGIN', --钢铁卫士自爆
                'UND_ADAMANTINEGOLEM_SUPERHEATED', --过热
                'LOW_RAPHAEL_SOUL', --灵魂充能
                'LOW_RAPHAEL_PILLAR_STATUS_VISUAL', --魂柱亲和
                'LOW_HOUSEOFHOPE_SOULPILLAR_FX', --魂柱
                'FLANKED', --受威胁
                'XIAN'
            },
            EGuiDebuff = {
                "SG_Condition",
                "SG_Blinded",
                "SG_Charmed",
                "SG_Cursed",
                "SG_Disease",
                "SG_Exhausted",
                "SG_Frightened",
                "SG_Incapacitated",
                "SG_Invisible",
                "SG_Poisoned",
                "SG_Prone",
                "SG_Restrained",
                "SG_Stunned",
                "SG_Unconscious",
                "SG_Paralyzed",
                "SG_Petrified",
                "SG_Poisoned_Story_Removable",
                "SG_Poisoned_Story_Nonremovable",
                "SG_Charmed_Subtle",
                "SG_Taunted",
                "SG_Approaching",
                "SG_Dominated",
                "SG_Fleeing",
                "SG_Confused",
                "SG_Mad",
                "SG_ScriptedPeaceBehaviour",
                "SG_DropForNonMutingDialog",
                "SG_HexbladeCurse",
                "SG_CanBePickedUp",
                "SG_Sleeping",
                "SG_Sleeping_Magical"
           },
           EGuiDebuff_Special = {
            "BLEEDING",
            "SHA_TRIALS_BLEEDING"
           }
        },
        BOOST = {
            Boosts = {
                "WeaponEnchantment",
                "WeaponProperty",
                "UnlockSpell"
            }
        }
    },
    Base = {
        Itemslot = {
            'Helmet',
            'Breast',
            'Cloak',
            'Melee Main Weapon',
            'Melee Offhand Weapon',
            'Ranged Main Weapon',
            'Ranged Offhand Weapon',
            'Ring',
            'Underwear',
            'Boots',
            'Gloves',
            'Amulet',
            'Ring2',
            'Wings',
            'Horns',
            'Overhead',
            'MusicalInstrument',
            'VanityBody',
            'VanityBoots',
        }
    },
    DanYao = {
        DropProbabilities = {
            YaoCai = {
                { id = 1,  factor = {1, 4}},  -- 白僵
                { id = 2,  factor = {1, 20}}, -- 碧藕
                { id = 3,  factor = {5, 20}}, -- 地涌金莲
                { id = 4,  factor = {1, 4}},  -- 甘草
                { id = 5,  factor = {1, 4}},  -- 葛蕈
                { id = 6,  factor = {5, 20}},-- 猴头菌
                { id = 7,  factor = {3, 10}}, -- 火灵砂
                { id = 8,  factor = {5, 20}}, -- 火铃草
                { id = 9,  factor = {5, 20}},-- 火枣
                { id = 10, factor = {5, 20}}, -- 交梨
                { id = 11, factor = {5, 20}},-- 九叶灵芝草
                { id = 12, factor = {1, 6}},  -- 老山参
                { id = 13, factor = {1, 6}},  -- 龙胆
                { id = 14, factor = {5, 20}},-- 千年人参
                { id = 15, factor = {1, 6}},  -- 树珍珠
                { id = 16, factor = {1, 6}},  -- 漱玉花
                { id = 17, factor = {3, 20}}  -- 紫芝
            },
            BaoCai = {
                { id = 1,  tag = {'aa374556-6257-4326-829f-7a9667e6fcb4'}, factor = {4, 1}, minlevel = 9, droplevel = 13},  -- 大力铁角 牛头人
                { id = 2,  tag = {'aaef5d43-c6f3-434d-b11e-c763290dbe0c','9a187721-0588-4f3c-ba9c-bff4989001b9','44be2f5b-f27e-4665-86f1-49c5bfac54ab','6abb4b64-51a7-4d63-9359-66f0047a6fe2','e9b781b3-40af-4d43-856c-e98b0694764c'}, factor = {2, 1}, minlevel = 5, droplevel = 13},  -- 妖生角
                { id = 3,  tag = {'8c8932c5-45f7-4d45-8f62-182db82ddcb0','0111a41a-d47f-42e5-a000-eea3f75e354d'}, factor = {1, 4}, minlevel = 5, droplevel = 13},  -- 黑色眼眸 蜘蛛，蛛化精灵
                { id = 4,  tag = {'b4ecfb1d-d8e6-4f2d-a003-0ed1f62b495b','9c79bbd4-c01c-4894-a2cf-51e1aae09a90'}, factor = {1, 2}, minlevel = 5, droplevel = 13},  -- 金色眼眸 眼魔
                { id = 7,  tag = {'95748ad1-cda2-4c0c-a9b2-875899327693'}, factor = {10, 1}, minlevel = 12}, -- 龙珠 龙
                { id = 8,  tag = {'22e5209c-eaeb-40dc-b6ef-a371794110c2'}, factor = {2}, minlevel = 5, droplevel = 13},  -- 铁中血 构装生物
                { id = 9,  tag = {'890b5a2a-e773-48df-b191-c887d87bec16'}, factor = {3}, minlevel = 5, droplevel = 9},   -- 玉锤牙 野兽
                { id = 10, tag = {'33c625aa-6982-4c27-904f-e47029a9b140'}, factor = {2}, minlevel = 9, droplevel = 13}   -- 震雷骨 不死生物
            }
        }
    },
    Zizhi = {
        ['BanXian_LingGen_T0'] = '先天道体',
        ['BanXian_LingGen_T1'] = '大帝之资',
        ['BanXian_LingGen_T2'] = '先天慧根',
        ['BanXian_LingGen_T3'] = '平平无奇',
        ['BanXian_LingGen_NIL'] = '灵根破碎'
    },
    LingGen = {
        ['BANXIAN_LG_H'] = '火',
        ['BANXIAN_LG_T'] = '土',
        ['BANXIAN_LG_J'] = '金',
        ['BANXIAN_LG_S'] = '水',
        ['BANXIAN_LG_M'] = '木'
    },
    LingGenXue = {
        BloodCurse = {
            "HAG_WELL_WORSE",
            "HAG_FLESHROT",
            "CONTAGION_FLESH_ROT",
            "PARALYZED",
            "CONTAGION_BLINDING_SICKNESS_1",
            "CONTAGION_BLINDING_SICKNESS_2",
            "CONTAGION_BLINDING_SICKNESS_3",
            "CONTAGION_FILTH_FEVER_1",
            "CONTAGION_FILTH_FEVER_2",
            "CONTAGION_FILTH_FEVER_3",
            "CONTAGION_FLESH_ROT_1",
            "CONTAGION_FLESH_ROT_2",
            "CONTAGION_FLESH_ROT_3",
            "CONTAGION_SLIMY_DOOM_1",
            "CONTAGION_SLIMY_DOOM_2",
            "CONTAGION_SLIMY_DOOM_3",
            "CONTAGION_SEIZURE_1",
            "CONTAGION_SEIZURE_2",
            "CONTAGION_SEIZURE_3",
            "CONTAGION_MINDFIRE_1",
            "CONTAGION_MINDFIRE_2",
            "CONTAGION_MINDFIRE_3",
            "MAG_POISON_POISON_LETHALITY"
        }
    },
    DaDao = {
    ['BanXian_DH_Tian'] = '天道',
    ['BanXian_DH_XiuLuo'] = '修罗道',
    ['BanXian_DH_RenJian'] = '人间道',
    ['BanXian_DH_ChuSheng'] = '畜生道',
    ['BanXian_DH_EGui'] = '饿鬼道',
    ['BanXian_DH_DiYu'] = '地狱道',
    ['BanXian_DH_Jian'] = '剑道',
    ['BanXian_DH_Li'] = '力道',
    ['BanXian_DH_HeHuan'] = '合欢道',
    ['BanXian_DH_Yi'] = '羿道'
    },
    ZhenFa = {
        LuoPan = {
            Caster = nil,
            X = nil,
            Z = nil
        },
        Core = {
            JuLing = {
                ToWards = {
                    ['ZhenFa_Flags_Qian'] = '西北',
                    ['ZhenFa_Flags_Kun'] = '西南',
                    ['ZhenFa_Flags_Xun'] = '东南',
                    ['ZhenFa_Flags_Zhen'] = '东',
                    ['ZhenFa_Flags_Kan'] = '北',
                    ['ZhenFa_Flags_Li'] = '南',
                    ['ZhenFa_Flags_Gen'] = '东北',
                    ['ZhenFa_Flags_Dui'] = '西'
                }
            }
        },
        Flags = {
            ['ZhenFa_Flags_Qian'] = '乾',
            ['ZhenFa_Flags_Kun'] = '坤',
            ['ZhenFa_Flags_Xun'] = '巽',
            ['ZhenFa_Flags_Zhen'] = '震',
            ['ZhenFa_Flags_Kan'] = '坎',
            ['ZhenFa_Flags_Li'] = '离',
            ['ZhenFa_Flags_Gen'] = '艮',
            ['ZhenFa_Flags_Dui'] = '兑'
        },
    },
    GongFa = {
        BaiMai = {}
    },
    Difficulty = {
        MessageBox = {
            default = "是否开启全员修仙？",
            Age = "请选择谪仙时代背景",
            Age_1 = "末法时代",
            Age_2 = "洪荒时代",
        },
        Race_DaDao = {
            { tag = '890b5a2a-e773-48df-b191-c887d87bec16',  DaDao_table = {'畜生道','力道'}},  -- 野兽
            { tag = '081a2ef4-dc1b-4d5b-bae3-8db81bef1d06',  DaDao_table = {'畜生道','力道'}}, -- 怪兽
            { tag = '44be2f5b-f27e-4665-86f1-49c5bfac54ab',  DaDao_table = {'修罗道','畜生道','地狱道','剑道','力道','合欢道'}}, -- 邪魔
            { tag = '9a187721-0588-4f3c-ba9c-bff4989001b9',  DaDao_table = {'修罗道','畜生道','地狱道','力道'}}, -- 恶魔
            { tag = '7cba0bd7-b955-4ac9-95ba-79e75978d9ac',  DaDao_table = {'天道','人间道'}}, -- 天界生物
            { tag = 'f6fd70e6-73d3-4a12-a77e-f24f30b3b424',  DaDao_table = {'畜生道','力道','合欢道'}}, -- 异怪
            { tag = '125b3d94-3997-4fc4-8211-1768b67dbe4a',  DaDao_table = {'畜生道','合欢道'}}, -- 植物
            { tag = '33c625aa-6982-4c27-904f-e47029a9b140',  DaDao_table = {'饿鬼道','地狱道'}}, -- 不死生物
            { tag = '7fbed0d4-cabc-4a9d-804e-12ca6088a0a8',  DaDao_table = {'修罗道','人间道','剑道','力道','合欢道'}} -- 类人生物
        },
        YiHuo = {
            {DisplayName = 'h7fa3812ege673g4f72gb6c6g829b1b50ca76', Fire = 'BANXIAN_Fire_of_Gold'}, --凯瑟里克·索姆
            {DisplayName = 'h62aeaf2bgee72g4274g9170gac359946c7d6', Fire = 'BANXIAN_Fire_of_Ghost'}, --指挥官扎尔克
            {DisplayName = 'h1ea7aa50g70c6g4ce4g85b2geedd37622b36', Fire = 'BANXIAN_Fire_of_ThreeMei'}, --拉斐尔
            {DisplayName = 'h82c5c29eg1f19g49efgba3dg4f8c3557c479', Fire = 'BANXIAN_Fire_of_Purple'}, --安苏
            {DisplayName = 'h14ff3592g1eb6g47b0g9350gc7434295b9bb', Fire = 'BANXIAN_Fire_of_SixDing' } --精金守卫
        }
    },
    FaBao = {
        ['ActiveMaterial'] = nil,
        GetThreshold = {6, 24, 54, 96, 150, 216, 294, 384, 486, 600},
        Base = {
        ["Boosts"] = "",
        ["DefaultBoosts"] = "",
        ["StatusOnEquip"] = "",
        ["PassivesOnEquip"] = ""
        },
        Weapon = {
            ["Boosts"] = "" ,
            ["DefaultBoosts"] = "",
            ["StatusOnEquip"] = "",
            ["PassivesOnEquip"] = "",
            ["BoostsOnEquipMainHand"] = "",
            ["BoostsOnEquipOffHand"] = "",
            ["PassivesMainHand"] = "",
            ["PassivesOffHand"] = "",
            ["WeaponFunctors"] = ""
        },
        All = {
            ["Boosts"] = "" ,
            ["DefaultBoosts"] = "",
            ["StatusOnEquip"] = "",
            ["PassivesOnEquip"] = "",
            ["BoostsOnEquipMainHand"] = "",
            ["BoostsOnEquipOffHand"] = "",
            ["PassivesMainHand"] = "",
            ["PassivesOffHand"] = "",
            ["WeaponFunctors"] = ""
        },
        BladPactStatus = {
            "PACT_BLADE",
            "MAG_WEAPON_BOND",
            "MAG_THE_THORNS_WEAPON_BOND",
            "END_CROWNCONTROLLER_BOUNDEDTO",
            "WYR_COURAGEBOUND",
            "WEAPON_BOND"
        },
        Materials_BaoCai = {
            BC_DaLiTieJiao = {
                Weapon = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_DaLiTieJiao_Weapon", ["WeaponFunctors"] = "DealDamage(1d4,Bludgeoning,Magical)"},
                Armor = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_DaLiTieJiao_Armor"},
                Ring = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_DaLiTieJiao_Ring"}
            },
            BC_YaoShengJiao = {
                Weapon = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_YaoShengJiao_Weapon", ["WeaponFunctors"] = "DealDamage(1d4,Psychic,Magical)"},
                Armor = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_YaoShengJiao_Armor"},
                Ring = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_YaoShengJiao_Ring"}
            },
            BC_HeiSeYanMou = {
                Weapon = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_HeiSeYanMou_Weapon", ["WeaponFunctors"] = "DealDamage(1d4,Necrotic,Magical)"},
                Armor = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_HeiSeYanMou_Armor", ["StatusOnEquip"] = "HEISEYANMOU_BOOST_ARMOR_TECHNICAL"},
                Ring = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_HeiSeYanMou_Ring",   ["StatusOnEquip"] = "HEISEYANMOU_BOOST_RING_TECHNICAL"}
            },
            BC_JinSeYanMou = {
                Weapon = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_JinSeYanMou_Weapon", ["WeaponFunctors"] = "DealDamage(1d4,Radiant,Magical)"},
                Armor = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_JinSeYanMou_Armor"},
                Ring = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_JinSeYanMou_Ring"}
            },
            BC_LongZhu = {
                Weapon = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_LongZhu_Weapon", ["WeaponFunctors"] = "DealDamage(1d6,Fire,Magical)"},
                Armor = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_LongZhu_Armor"},
                Ring = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_LongZhu_Ring"}
            },
            BC_TieZhongXue = {
                Weapon = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_TieZhongXue_Weapon", ["WeaponFunctors"] = "DealDamage(1d4,Slashing,Magical)"},
                Armor = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_TieZhongXue_Armor", ["StatusOnEquip"] = "TIEZHONGXUE_BOOST_ARMOR_TECHNICAL"},
                Ring = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_TieZhongXue_Ring"}
            },
            BC_YuChuiYa = {
                Weapon = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_YuChuiYa_Weapon", ["WeaponFunctors"] = "DealDamage(1d4,Piercing,Magical)"},
                Armor = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_YuChuiYa_Armor"},
                Ring = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_YuChuiYa_Ring"}
            },
            BC_ZhenLeiGu = {
                Weapon = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_ZhenLeiGu_Weapon", ["WeaponFunctors"] = "DealDamage(1d6,Lightning,Magical)"},
                Armor = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_ZhenLeiGu_Armor"},
                Ring = {["PassivesOnEquip"] = "BanXian_Fabao_Material_BC_ZhenLeiGu_Ring"}
            }
        }
    },
}

-- 持久化数据
Variables.Persistent = {
    Difficulty = {}
}




return Variables
