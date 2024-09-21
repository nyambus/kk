<?php
if (isset($_FILES['file'])) {
    move_uploaded_file($_FILES['file']['tmp_name'], './uploads/' . $_FILES['file']['name']);
}
?>
<form action="" method="POST" enctype="multipart/form-data">
    <input type="file" name="file" />
    <input type="submit" value="Загрузить" />
</form>
