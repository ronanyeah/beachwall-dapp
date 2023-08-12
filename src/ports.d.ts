interface ElmApp {
  ports: Ports;
}

interface Ports {
  connect: PortOut<null>;
  log: PortOut<string>;
  edit: PortOut<{ n: number; col: number[] }>;
  connectResponse: PortIn<string>;
  disconnect: PortIn<null>;
  editResponse: PortIn<boolean>;
  squareChange: PortIn<number[][]>;
}

interface PortOut<T> {
  subscribe: (_: (_: T) => void) => void;
}

interface PortIn<T> {
  send: (_: T) => void;
}

export { ElmApp };
