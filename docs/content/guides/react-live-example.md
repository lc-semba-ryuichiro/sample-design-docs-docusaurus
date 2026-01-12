---
sidebar_position: 10
---

# React コンポーネント実装例

このページでは、ライブコードブロック機能を使って React コンポーネントの実装例とレンダリング結果を同時に表示する方法を示します。

## 基本的な使い方

コードブロックに `live` を付けると、コードがそのままレンダリングされます。

```jsx live
function HelloWorld() {
  return <h1 style={{color: '#25c2a0'}}>Hello, World!</h1>
}
```

:::tip
上のコードを編集すると、リアルタイムでレンダリング結果が更新されます。
:::

## state を使った例

`useState` などの React Hooks は自動的にスコープに含まれています。

```jsx live
function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div style={{textAlign: 'center', padding: '20px'}}>
      <p style={{fontSize: '24px', fontWeight: 'bold'}}>
        カウント: {count}
      </p>
      <button
        onClick={() => setCount(count + 1)}
        style={{
          padding: '10px 20px',
          fontSize: '16px',
          cursor: 'pointer',
          backgroundColor: '#25c2a0',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          marginRight: '8px'
        }}
      >
        +1
      </button>
      <button
        onClick={() => setCount(0)}
        style={{
          padding: '10px 20px',
          fontSize: '16px',
          cursor: 'pointer',
          backgroundColor: '#fa383e',
          color: 'white',
          border: 'none',
          borderRadius: '4px'
        }}
      >
        リセット
      </button>
    </div>
  );
}
```

## useEffect の例

副作用を伴うコンポーネントも記述できます。

```jsx live
function Timer() {
  const [seconds, setSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  useEffect(() => {
    let interval = null;
    if (isRunning) {
      interval = setInterval(() => {
        setSeconds(s => s + 1);
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [isRunning]);

  return (
    <div style={{textAlign: 'center', padding: '20px'}}>
      <p style={{fontSize: '32px', fontFamily: 'monospace'}}>
        {Math.floor(seconds / 60).toString().padStart(2, '0')}:
        {(seconds % 60).toString().padStart(2, '0')}
      </p>
      <button
        onClick={() => setIsRunning(!isRunning)}
        style={{
          padding: '8px 16px',
          marginRight: '8px',
          cursor: 'pointer'
        }}
      >
        {isRunning ? '停止' : '開始'}
      </button>
      <button
        onClick={() => { setSeconds(0); setIsRunning(false); }}
        style={{padding: '8px 16px', cursor: 'pointer'}}
      >
        リセット
      </button>
    </div>
  );
}
```

## 書き方

Markdown ファイルで以下のように記述します：

````markdown
```jsx live
function MyComponent() {
  return <div>編集可能なコード</div>
}
```
````

## 制約事項

- `import` 文は使用できません
- `useState`, `useEffect`, `useRef` などの基本的な React Hooks は自動的に利用可能です
- 外部ライブラリは使用できません（React と基本的な Hooks のみ）
