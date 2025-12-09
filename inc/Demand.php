<?php
require "Connection.php";
class Demand
{
    private $car;

    public function __construct($car)
    {
        $this->car = $car;
    }
   
    public function carlogin($username, $password, $tblname)
    {
         $licenseResult = $this->licensevalidate();
         if ($licenseResult == 1) {
            $q = "SELECT * FROM " . $tblname . " WHERE username='" . $username . "' AND password='" . $password . "'";
            return $this->car->query($q)->num_rows;
         }
         else 
         {
          return -1;   
         }
        
    }

    public function carinsertdata($field, $data, $table)
    {
        $licenseResult = $this->licensevalidate();
         if ($licenseResult == 1) {
        $field_values = implode(",", $field);
        $data_values = implode("','", $data);

        $sql = "INSERT INTO $table($field_values)VALUES('$data_values')";
        return $this->car->query($sql);
         }
         else 
         {
          return -1;   
         }
    }

    

    
}
?>
