module ArrayArithmetic
  def add_arrs(arr1, arr2)
    raise "Can only add 2D vecs!" unless arr1.length == 2 and arr2.length == 2

    [arr1[0] + arr2[0], arr1[1] + arr2[1]]
  end

  def subtract_arrs(arr1, arr2)
    raise "Can only subtract 2D vecs!" unless arr1.length == 2 and arr2.length == 2

    [arr1[0] - arr2[0], arr1[1] - arr2[1]]
  end

  def midpoint(arr1, arr2)
    difference = subtract_arrs(arr1, arr2)
    half_step = [difference[0] / 2, difference[1] / 2]
    add_arrs(arr2, half_step)
  end
end
