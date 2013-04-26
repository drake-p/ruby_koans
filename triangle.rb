# Triangle Project Code.

# Triangle analyzes the lengths of the sides of a triangle
# (represented by a, b and c) and returns the type of triangle.
#
# It returns:
#   :equilateral  if all sides are equal
#   :isosceles    if exactly 2 sides are equal
#   :scalene      if no sides are equal
#
# The tests for this method can be found in
#   about_triangle_project.rb
# and
#   about_triangle_project_2.rb
#
def triangle(a, b, c)
	sides = [a,b,c].sort

	raise TriangleError, "Side lengths must be positive" 	if sides[0] <= 0
	raise TriangleError, "Each side length must be less than the sum of the other two" 	if sides[2] >= sides[1] + sides[0]

  if sides[0] == sides[1] and sides[1] == sides[2]
	  :equilateral
  elsif sides[0] != sides[1] and sides[1] != sides[2]
  	:scalene
  else
  	:isosceles
  end
end

# A more concise solution from Stack Overflow:
#
# def triangle(*args)
#   args.sort!
#   raise TriangleError if args[0] + args[1] <= args[2] || args[0] <= 0
#   [nil, :equilateral, :isosceles, :scalene][args.uniq.length]
# end

# Error class used in part 2.  No need to change this code.
class TriangleError < StandardError
end
