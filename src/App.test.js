import { render, screen } from '@testing-library/react';
import App from './App';

test('renders Dirtmate link', () => {
  render(<App />);
  const linkElement = screen.getByText(/explore dirtmate/i);
  expect(linkElement).toBeInTheDocument();
});
