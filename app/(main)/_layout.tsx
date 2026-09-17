import { Tabs } from 'expo-router';

export default function MainLayout() {
  return <Tabs screenOptions={{ headerShown: false, tabBarIconStyle: { display: 'none' }, tabBarActiveTintColor: '#111111', tabBarInactiveTintColor: '#737373', tabBarLabelStyle: { fontSize: 13, fontWeight: '600' }, tabBarStyle: { borderTopColor: '#e5e7eb' } }}>
    <Tabs.Screen name="home" options={{ title: 'Главная' }} />
    <Tabs.Screen name="booking" options={{ title: 'Заказать' }} />
    <Tabs.Screen name="order" options={{ title: 'Заказ' }} />
    <Tabs.Screen name="history" options={{ title: 'История' }} />
  </Tabs>;
}
