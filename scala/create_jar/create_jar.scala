package create_jar
class Person(val firstName: String, val lastName: String) {
  
  println("the constructor begins")
  
  val fullName = firstName + " " + lastName
  
  def printFullName {
    // access the fullName field, which is created above
    println(fullName) 
  }

   printFullName

   println("Isn't this fun")

}