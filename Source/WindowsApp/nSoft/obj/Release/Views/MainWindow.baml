   M S B A M L   `   `   `  ���� @  <nSoft, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullclr-namespace:nSoftnSoft  3clr-namespace:nSoft.PropertiesnSoft.Properties  3clr-namespace:nSoft.ViewModelsnSoft.ViewModels  3clr-namespace:nSoft.ConvertersnSoft.Converters      nSoft.MainWindow   W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     @d2http://schemas.microsoft.com/expression/blend/2008     Z VFontAwesome.WPF, Version=4.7.0.37774, Culture=neutral, PublicKeyToken=0758b07a11a4f466-fa$http://schemas.fontawesome.io/icons/  localclr-namespace:nSoft  Dmc;http://schemas.openxmlformats.org/markup-compatibility/2006  &pclr-namespace:nSoft.Properties  /
viewModelsclr-namespace:nSoft.ViewModels  /
convertersclr-namespace:nSoft.Converters  -   $	��550��$	��500��  � 
ResizeMode$  NoResize=� � Title$ nSoft�� � 	Resources    HeaderStyle �� 
TargetType �� Property �� Value  HeaderBtnStyle  InputboxStyle$   nSoft.ViewModels.MainViewModel  	ViewModel0   *nSoft.Converters.BoolToVisibilityConverter  BoolToVisibilityConverter��%�  &	        &	 n     &	     &	 �    &	 �    �� " ��.���  � ��$ Right=���  � ��$	 Top=���  � ��$ Arial)���  � ��$
 16px(��� " ��.���  � ��$ Center=���  � ��$ Center=���  � ��$ Arial)���  � ��$
 16px(���  � ��$	 100����  � ��$ 30���� " ��.���  � ��$	 330����  � ��$ 25����  � ��$
 Left=���  � ��$	 Top=���  � ��$ Arial)���  � ��$
 16px(���  � ��$ 0 3 0 0q�     � DataContext ��  �� ResourceKey$ 	ViewModel��.���  � RowDefinitions �� $��2* ��� $��5* �.+��� $��
15 15 15 0q�$
��14px(�$��Database information��{��� *IsNotConnectedDatabase+y��� *IsNotConnectingDB+	 �� 	Converter#	 [ .���  �� $��1* ��� $��2* ��� $��2* ��� $
��0.7* �
 � ColumnDefinitions
 �� $
��0.5* ��� $
��2.5* ��� $
��0.2* ��� $��8* ��� $
��0.5* �.+��� $��1��$��1��$��Server name��#��[  �� -    ��Name$ txtServerName��$��1��$��3��#��[ ���� *TxtServerName+�� -    ��Name$ 
btnConnect��$��2��$��5��$��Connect��#��[ ���� *ConnectDatabaseCommand+�� $��2��$��15q�$
��14px(�$��Machine information��y��� *IsNotConnectingDB+#	 [ .���  �� $	��20* ��� $	��41* ��� $	��22* ��� $	��19* ��� $
��123* ��� $	��41* ��� $	��14* �
 �� $
��0.5* ��� $
��2.5* ��� $
��0.2* ��� $��8* ��� $
��0.5* �.+��� $��1��$��1��$��
Machine ID��#��[  �� -   $ txtMachineID��$��1��$��3�� �� 
IsReadOnly . #��[ ���� *TxtMachineID+�� $��2��$��1��$��Status��#��[  $��2���� -   $ 	txtStatus��$��2��$��3�� . #��[ $��2������ *	TxtStatus+�� $��4��$��1��$��Message Log��#��[  �� -   $ txtMessageLog��$��4��$��3��$	��110�� . " �� VerticalScrollBarVisibility$
 Auto=�#��[  �� TextWrapping$
 Wrap=� �� AcceptsReturn . $��12(����� *TxtLog+]� $��5��$��3��$��Center=�$��	48,0,48,0q�.+��� -   $ btnStart��$��Start��#��[ ���� *StartServiceCommand+{��� *IsStoppedService+�� -   $ btnStop��$��40 0 0 0q�$
��Stop��#��[ ���� *StopServiceCommand+{��� *IsRunningService+"  FontAwesome.WPF.ImageAwesome  -	     Name$ Spinner��$��2��$��60��$��200 140 200 190q� K� ZIndex$ -1��   
Foreground
 �����   Icon$ Spinner=�   Spin .    SpinDuration$ 4Q�y��� *IsConnectingDB+#	 [ �� $��2��$��0 50 0 0q�$��Center=�$��Center=�$��Connecting to database��#��[  y��� *IsConnectingDB+#	 [ 