# Struktur game — CENTAURA

> Dibuat otomatis oleh `database/tools/sort_dumps.py` dari `memory/*.json`. JANGAN edit manual. Batch terakhir: `20261125_083600`.
> Nama pemain diganti `<PLAYER>`; saudara kembar digabung `×N`. `*` = script, `!` = remote.

## Lighting

```
Atmosphere [Atmosphere]
ColorCorrection [ColorCorrectionEffect]
ConcussionFilter [ColorCorrectionEffect]
ExplosionBlur [BlurEffect]
Sky [Sky]
SunRays [SunRaysEffect]
SuppressionBlurEffect [BlurEffect]
```

## Players

```
<PLAYER> [Player] ×64
```

## ReplicatedFirst

```
```

## ReplicatedStorage

```
56a05903-8631-4bc9-bc8c-74fc656fa25c [RemoteEvent] !
AdminEndMatch [RemoteEvent] !
ArtilleryTracer [RemoteEvent] !
AutoTeamBalance [BoolValue]
BeginIntermission [BindableEvent]
BloodEffects [RemoteEvent] !
BloodSplatter [BindableEvent]
BoundariesEnabled [BoolValue]
CUSTOM_ArtilleryDisabled [BoolValue]
CUSTOM_ManualMatchStart [BoolValue]
CUSTOM_MapRotationDisabled [BoolValue]
CUSTOM_PointGainDisabled [BoolValue]
CUSTOM_VehiclesDisabled [BoolValue]
CameraShaker [ModuleScript] *
ChangeTeam [RemoteEvent] !
ChooseClass [RemoteEvent] !
ClassSelectionMenu [Frame]
Click [ImageButton]
ClientNotification [BindableEvent]
ClientVehicleHitboxes [Folder]
  AntaresArmoredCar [Model]
  CetusArmoredCar [Model]
  CorvusArmoredCar [Model]
Concussion [RemoteEvent] !
CurrentMap [StringValue]
CurrentYear [IntValue]
CustomEquipmentDictionary [ModuleScript] *
CustomEquipmentDictionarySAVE [ModuleScript] *
CustomInventoryAssets [Folder]
  BackpackView [ModuleScript] *
  InventoryInstances [Folder]
CutsceneAssets [ModuleScript] *
CutsceneModule [ModuleScript] *
Daze [BindableEvent]
Deaths [IntValue]
DefaultSoundEvents [Folder]
  AddCharacterLoadedEvent [RemoteEvent] !
  DefaultServerSoundEvent [RemoteEvent] !
  RemoveCharacterEvent [RemoteEvent] !
  SoundDispatcher [BindableEvent]
DynamiteStick [Model]
  Detonate [BindableEvent]
  DynamiteHandler [Script] *
  DynamiteStick [MeshPart]
  Humanoid [Humanoid]
Functions [Folder]
  Ban [RemoteFunction] !
  Handshake [RemoteEvent] !
  Kick [RemoteEvent] !
GAME_FirstLoad [BoolValue]
GAME_MapLoaded [BoolValue]
Gib [UnionOperation]
GrenadeThrow [Animation]
HelmetShot [RemoteEvent] !
InMatch [BoolValue]
InTransition [BoolValue]
Intermission [BoolValue]
IntermissionEvent [RemoteEvent] !
LOCAL_CameraAngle [NumberValue]
LOCAL_InStartMenu [BoolValue]
LOCAL_PlayerBackpackEnabled [BoolValue]
LOCAL_SelectedClass [StringValue]
LoadCharacter [RemoteEvent] !
LoadLibrary [Folder]
  RbxGui [ModuleScript] *
  RbxStamper [ModuleScript] *
  RbxUtility [ModuleScript] *
ManualMatchStart [BindableEvent]
MapLoaded [BoolValue]
MortarAssets [Folder]
  MortarAimIndicator [Model]
  MortarAimIndicatorOLD [Model]
  ReticleDot [Part]
  ReticlesFolder [Folder]
MortarFire [RemoteEvent] !
MouseOverModule [ModuleScript] *
MovementSounds [Folder]
  MaterialSounds [Folder]
  Sounds [Folder]
NotificationAssets [ModuleScript] *
OpenShopUI [RemoteEvent] !
OutOfBounds [RemoteEvent] !
PerksDictionary [ModuleScript] *
PlaceablesPreviews [Folder]
  TrenchShieldPreview [Model]
RankUpNotification [RemoteEvent] !
RaycastHitboxModule [ModuleScript] *
RemoteFloodCheck [ModuleScript] *
RemoveGripWeld [RemoteEvent] !
RemoveWire [RemoteEvent] !
ReplicatedTweening [ModuleScript] *
RequestClass [RemoteFunction] !
RequestCustomEquipment [RemoteFunction] !
RequestPerkEquip [RemoteFunction] !
RequestShopPurchase [RemoteFunction] !
RoundClock [IntValue]
ServerListRemotes [Folder]
  ClientUpdateServers [RemoteEvent] !
  JoinServer [RemoteEvent] !
  UpdateServers [RemoteEvent] !
ServerNotification [RemoteEvent] !
ShopItemDictionary [ModuleScript] *
SpringModule [ModuleScript] *
Status [StringValue]
SunFlareColor [Color3Value]
Suppression [BindableEvent]
SystemChat [RemoteEvent] !
TREKModules [Folder]
  GlobalSettings [ModuleScript] *
  GunSettings [Folder]
  MeleeHit [Sound]
  TweenModule [ModuleScript] *
TREKRemotes [Folder]
  BulletBind [BindableEvent]
  BulletRemote [RemoteEvent] !
  DamageRemote [UnreliableRemoteEvent]
  DamagerRemote [RemoteEvent] !
  FlashBind [BindableEvent]
  FlashRemote [RemoteEvent] !
  KillfeedRemote [RemoteEvent] !
  PenBind [BindableEvent]
  PenRemote [RemoteEvent] !
  PersonalfeedRemote [RemoteEvent] !
  ReloadRemote [RemoteEvent] !
TREKScripts [Folder]
  Gun [LocalScript] *
  GunSAVE [LocalScript] *
  Gun_ [LocalScript] *
TREKStorage [Folder]
  BulletGlow [BillboardGui]
  BulletTemp [Part]
  Charge [Animation]
  Crouch [Animation]
  Medkit [Model]
  Particles [Part]
  ParticlesOLD [Part]
  Roll [Animation]
  Run [Animation]
  Walk [Animation]
Team1 [ObjectValue]
Team2 [ObjectValue]
TweenEvent [RemoteEvent] !
TweenModule [ModuleScript] *
UpdateSettings [BindableEvent]
VK [RemoteEvent] !
Victor [StringValue]
Viewmodel [Model]
  AnimationController [AnimationController]
  HeadWeld [Weld]
  HumanoidRootPart [Part]
  Torso [Part]
ViewmodelBox [Part]
ViewmodelSAVE [Model]
  AnimationController [AnimationController]
  Head [Part]
  HeadWeld [Weld]
  HumanoidRootPart [Part]
  Left Arm [Part]
  Right Arm [Part]
  Torso [Part]
Voiceline [RemoteEvent] !
Voicelines [Folder]
  English [Folder]
  ExplosionDeathScreams [Folder]
  MaskLoudener [CompressorSoundEffect]
  MaskMuffle [EqualizerSoundEffect]
  Portuguese [Folder]
  WarCries [Folder]
Votekick [RemoteEvent] !
VotekickValues [Folder]
  1234_Dregq [IntValue]
  1notalexander4 [IntValue]
  1ubybyggzk [IntValue]
  3e3e3yirtjil [IntValue]
  59goated1 [IntValue]
  Aarav_Eggo [IntValue]
  Afoc_8aXD [IntValue]
  Ahimigatito [IntValue]
  BluZombie208 [IntValue]
  COVARACHO78 [IntValue]
  Cocaferia0 [IntValue]
  Cwcoolboy1 [IntValue]
  DaniloW50 [IntValue]
  Dustmover112 [IntValue]
  ElCapoMessi1812 [IntValue]
  FEARDAFFYBADUSERNAME [IntValue]
  Galaxy_noodles123 [IntValue]
  Gavinroi24 [IntValue]
  Iheartspace03 [IntValue]
  Imperial_Italy2 [IntValue]
  JULIO2005e [IntValue]
  KINGbob01094 [IntValue]
  Mrs_OfTheLily [IntValue]
  PuroTheGreat21 [IntValue]
  Raxtusv [IntValue]
  Robloxremix14 [IntValue]
  Sadbooyz13 [IntValue]
  Sandviper_th3 [IntValue]
  Skeletalistic [IntValue]
  Stanley4510 [IntValue]
  TYTTRkl [IntValue]
  Thiago3a1ioe [IntValue]
  TideBraker [IntValue]
  TinyScrub [IntValue]
  Veneno818718 [IntValue]
  WesternEastNorth [IntValue]
  angelon123xdd [IntValue]
  anuelnoob [IntValue]
  atgamer37 [IntValue]
  banana_chum7 [IntValue]
  bobmaniscoolpoop [IntValue]
  borrega247 [IntValue]
  brandonbarberertioc [IntValue]
  coolcookieboss12345 [IntValue]
  darthnihilus_66 [IntValue]
  dratlast [IntValue]
  dudelegand98 [IntValue]
  dylanspiderss [IntValue]
  frnxster [IntValue]
  gerson8352 [IntValue]
  hamstermannster [IntValue]
  josevar7987 [IntValue]
  matexd809 [IntValue]
  memo1117872 [IntValue]
  renrenhu6 [IntValue]
  roblox_user_1416249619 [IntValue]
  samirch08 [IntValue]
  sammy868792 [IntValue]
  shadownan_2008 [IntValue]
  skeletonbud20113 [IntValue]
  skyguy1451 [IntValue]
  tengonovia_248 [IntValue]
  traincrash2007 [IntValue]
  turtle23874 [IntValue]
  xXxPIMBLOxXx [IntValue]
  xxn00bslayerxxx7 [IntValue]
  zhaul2016 [IntValue]
WhistleCharge [RemoteEvent] !
Zone [ModuleScript] *
ZonePlusReference [ObjectValue]
```

## StarterGui

```
AmbientTexture [ScreenGui]
AttentivePerkUI [ScreenGui]
ChangelogGUI [ScreenGui]
CustomEquipmentShopUI [ScreenGui]
CustomInventory [ScreenGui]
DamageGui [ScreenGui]
DeathCounter [ScreenGui]
DeathScreen [ScreenGui]
Disorientation [ScreenGui]
EquipmentShopUI [ScreenGui]
FreecamDetector [ScreenGui]
MobileUI [ScreenGui]
PlayerListGui [ScreenGui]
PlayerNametags [ScreenGui]
RankUpUI [ScreenGui]
ReturnToCombatZone [ScreenGui]
SpawnMenuUI [ScreenGui]
TREKHud [ScreenGui]
Tense [ScreenGui]
TopBar [ScreenGui]
UniqueMapEffects [ScreenGui]
```

## StarterPlayer

```
StarterCharacter [Model]
  Animate [LocalScript] *
  Body Colors [BodyColors]
  Head [Part]
  Humanoid [Humanoid]
  HumanoidRootPart [Part]
  Left Arm [Part]
  Left Leg [Part]
  Right Arm [Part]
  Right Leg [Part]
  Torso [Part]
StarterCharacterScripts [StarterCharacterScripts]
StarterPlayerScripts [StarterPlayerScripts]
```

## Workspace

```
<PLAYER> [Model] ×64
  ALBUS-GRAHAM NO. 4 [Tool] ×2
  Animate [LocalScript] ×64 *
  BANDAGES [Tool]
  BARTON MODEL 10 [Tool] ×2
  BERSERKER [IntValue]
  Body Colors [BodyColors] ×64
  BrowPlate [Model] ×2
  BurnAnimation [LocalScript] ×64 *
  CLUB [Tool]
  COOLHEADED [IntValue] ×4
  CameraBlock [Part]
  CameraBobbing [LocalScript] ×64 *
  CameraSystem [LocalScript] ×64 *
  CharacterHair [Accessory] ×53
  CivilGuard10Pants [Pants] ×2
  CivilGuard10Shirt [Shirt] ×2
  CivilGuard1Pants [Pants] ×2
  CivilGuard1Shirt [Shirt] ×2
  CivilGuard4Pants [Pants] ×2
  CivilGuard4Shirt [Shirt] ×2
  CivilGuardHat2 [Model]
  CivilGuardHat3 [Model]
  CivilGuardHat5 [Model]
  CivilGuardHat8 [Model]
  CivilGuardPoliceBelt [Model] ×2
  CivilGuardPoliceCap [Model] ×2
  CivilGuardWebbing1 [Model]
  CivilGuardWebbing3 [Model] ×2
  CivilGuardWebbing5 [Model]
  ClassGiven [StringValue] ×53
  DECIMA SHOTGUN [Tool] ×2
  DYNAMITE [Tool]
  DamageResistanceMultiplier [IntValue] ×64
  E/I AT RIFLE [Tool] ×2
  E/VIII RIFLE BAYONET [Tool] ×7
  E/VIII RIFLE [Tool]
  E/XV AUTOMATIC [Tool] ×4
  ENE AERA RIFLE [Tool] ×5
  FIGHT-OR-FLIGHT [BoolValue] ×6
  FallDamage [Script] ×64 *
  Head [Part] ×64
  HeadFaceDirt [Model] ×53
  HeadTurn [LocalScript] ×64 *
  Health [Script] ×64 *
  Helmet [Model] ×43
  Humanoid [Humanoid] ×64
  HumanoidHandler [LocalScript] ×64 *
  HumanoidRootPart [Part] ×64
  HumanoidStatesHandler [LocalScript] ×64 *
  JumpCooldown [LocalScript] ×64 *
  Left Arm [Part] ×64
  Left Leg [Part] ×64
  LocalFootsteps [LocalScript] ×64 *
  M12 AT RIFLE [Tool] ×2
  M12 SMG [Tool] ×4
  M1889 LA RIFLE BAYONET [Tool] ×2
  M4 REVOLVER [Tool]
  M99 RIFLE BAYONET [Tool] ×10
  M99 RIFLE [Tool]
  MODELO 1898 RIFLE BAYONET [Tool]
  MORTAR [Tool] ×2
  Medic1912Pants [Pants] ×3
  Medic1912Shirt [Shirt] ×3
  MovementSpeedHandler [LocalScript] ×64 *
  Officer1912Pants [Pants] ×2
  Officer1912Shirt [Shirt] ×2
  OfficerBelt1912 [Model] ×2
  OfficerCap [Model] ×2
  OfficerCap1912 [Model] ×2
  OfficerPants [Pants] ×2
  OfficerShirt [Shirt] ×2
  PlaceablesHandler [LocalScript] ×64 *
  Rig [Model] ×23
  Rig1912 [Model] ×22
  Right Arm [Part] ×64
  Right Leg [Part] ×64
  SUB E/XCV SL [Tool] ×2
  SmoothWalkLean [LocalScript] ×64 *
  Sound [Script] ×64 *
  Standard1912Pants [Pants] ×19
  Standard1912Shirt [Shirt] ×19
  StandardPants [Pants] ×21
  StandardShirt [Shirt] ×21
  TREKLocal [LocalScript] ×64 *
  TeamIndicator [LocalScript] ×64 *
  Torso [Part] ×64
  UPARMORED [IntValue] ×2
  ViewmodelHandler [LocalScript] ×64 *
  Voicelines [Script] ×64 *
AirburstMortarExplosion [Explosion]
AirburstMortarExplosionEffectPart [Part]
BloodCache [Folder]
  BloodPart [Part] ×108
Camera [Camera]
Grenades [Folder]
  Grenade [Part]
IgnoreList [Folder]
  Bullets [Folder]
  MapParts [Folder]
  PlayingZone [Folder]
  Tracers [Folder]
  VehicleHitboxes [Folder]
JOB_ID [StringValue]
LobbyRoom [Folder]
  LobbyRoom [Model]
  LobbySpawns [Folder]
Map [Folder]
  Map [Folder]
MortarShrapnelImpact [Part] ×143
MortarWhistle [Part] ×9
PLACE_VERSION [StringValue]
Placeables [Folder]
Previews [Folder]
Sounds [Folder]
  BattleEnd [Sound]
  BulletWhiz [Sound]
  Click [Sound]
  Click2 [Sound]
  FlamethrowerIgnition [Sound]
  KillConfirmed [Sound]
  Morse [Folder]
  Music [Folder]
  OceanWavesAmbience [Sound]
  PianoImpact [Sound]
  PointCaptured [Sound]
  RadioCrackle [Sound]
  RankUp [Sound]
  TrenchWhistle [Sound]
Terrain [Terrain]
VehicleExplosionEffectPart [Part]
VehicleWeaponTargets [Folder]
  Vehicle [ObjectValue] ×3
```

