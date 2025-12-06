class Position:
    def __init__(self, x: int, y: int):
        self.x = x
        self.y = y
        
    def is_equal(self, position_to_compare) -> bool:
        if (position_to_compare.x == self.x):
            if(position_to_compare.y == self.y):
                return True
        return False

    def __eq__(self, other):
        if isinstance(other, Position):
            return self.x == other.x and self.y == other.y
        return False

    def __hash__(self):
        return hash((self.x, self.y))

    def __repr__(self):
        return f"Position(x={self.x}, y={self.y})"