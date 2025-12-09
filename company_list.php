<?php
require 'inc/checklogin.php';
require 'inc/Connection.php';
require 'inc/header.php';

// Handle status update
if (isset($_GET['action']) && isset($_GET['id'])) {
    $id = intval($_GET['id']);
    $action = $_GET['action'];
    
    switch ($action) {
        case 'activate':
            $car->query("UPDATE tbl_company SET status = 'active' WHERE id = $id");
            $msg = "Company activated successfully";
            break;
        case 'suspend':
            $car->query("UPDATE tbl_company SET status = 'suspended' WHERE id = $id");
            $msg = "Company suspended";
            break;
        case 'verify':
            $car->query("UPDATE tbl_company SET is_verified = 1 WHERE id = $id");
            $msg = "Company verified";
            break;
        case 'delete':
            $car->query("DELETE FROM tbl_company WHERE id = $id");
            $msg = "Company deleted";
            break;
    }
    
    echo "<script>alert('$msg'); window.location='company_list.php';</script>";
}

// Filters
$where = "1=1";
if (!empty($_GET['status'])) {
    $status = $car->real_escape_string($_GET['status']);
    $where .= " AND status = '$status'";
}
if (!empty($_GET['verified'])) {
    $verified = intval($_GET['verified']);
    $where .= " AND is_verified = $verified";
}
if (!empty($_GET['search'])) {
    $search = $car->real_escape_string($_GET['search']);
    $where .= " AND (company_name LIKE '%$search%' OR email LIKE '%$search%')";
}

// Pagination
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$limit = 20;
$offset = ($page - 1) * $limit;

$total = $car->query("SELECT COUNT(*) as cnt FROM tbl_company WHERE $where")->fetch_assoc()['cnt'];
$companies = $car->query("SELECT c.*, 
    (SELECT COUNT(*) FROM tbl_car WHERE company_id = c.id) as car_count,
    (SELECT COUNT(*) FROM tbl_book b JOIN tbl_car tc ON b.car_id = tc.id WHERE tc.company_id = c.id) as booking_count
    FROM tbl_company c WHERE $where ORDER BY c.id DESC LIMIT $limit OFFSET $offset");
?>

<div class="page-wrapper">
    <div class="page-content">
        <div class="page-breadcrumb d-none d-sm-flex align-items-center mb-3">
            <div class="breadcrumb-title pe-3">Company Management</div>
            <div class="ps-3">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0 p-0">
                        <li class="breadcrumb-item"><a href="dashboard.php"><i class="bx bx-home-alt"></i></a></li>
                        <li class="breadcrumb-item active">Companies</li>
                    </ol>
                </nav>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row mb-4">
            <?php
            $stats = $car->query("SELECT 
                COUNT(*) as total,
                SUM(status = 'active') as active,
                SUM(status = 'pending') as pending,
                SUM(status = 'suspended') as suspended,
                SUM(is_verified = 1) as verified
            FROM tbl_company")->fetch_assoc();
            ?>
            <div class="col-md-2">
                <div class="card radius-10 bg-primary">
                    <div class="card-body text-center">
                        <h4 class="text-white"><?= $stats['total'] ?></h4>
                        <p class="mb-0 text-white">Total</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card radius-10 bg-success">
                    <div class="card-body text-center">
                        <h4 class="text-white"><?= $stats['active'] ?></h4>
                        <p class="mb-0 text-white">Active</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card radius-10 bg-warning">
                    <div class="card-body text-center">
                        <h4 class="text-white"><?= $stats['pending'] ?></h4>
                        <p class="mb-0 text-white">Pending</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card radius-10 bg-danger">
                    <div class="card-body text-center">
                        <h4 class="text-white"><?= $stats['suspended'] ?></h4>
                        <p class="mb-0 text-white">Suspended</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="card radius-10 bg-info">
                    <div class="card-body text-center">
                        <h4 class="text-white"><?= $stats['verified'] ?></h4>
                        <p class="mb-0 text-white">Verified</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-3">
                        <input type="text" name="search" class="form-control" placeholder="Search company..." value="<?= $_GET['search'] ?? '' ?>">
                    </div>
                    <div class="col-md-2">
                        <select name="status" class="form-select">
                            <option value="">All Status</option>
                            <option value="active" <?= ($_GET['status'] ?? '') == 'active' ? 'selected' : '' ?>>Active</option>
                            <option value="pending" <?= ($_GET['status'] ?? '') == 'pending' ? 'selected' : '' ?>>Pending</option>
                            <option value="suspended" <?= ($_GET['status'] ?? '') == 'suspended' ? 'selected' : '' ?>>Suspended</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <select name="verified" class="form-select">
                            <option value="">Verification</option>
                            <option value="1" <?= ($_GET['verified'] ?? '') == '1' ? 'selected' : '' ?>>Verified</option>
                            <option value="0" <?= ($_GET['verified'] ?? '') == '0' ? 'selected' : '' ?>>Unverified</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary">Filter</button>
                        <a href="company_list.php" class="btn btn-secondary">Reset</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Companies Table -->
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Company</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Cars</th>
                                <th>Bookings</th>
                                <th>Commission</th>
                                <th>Status</th>
                                <th>Verified</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while ($row = $companies->fetch_assoc()): ?>
                            <tr>
                                <td><?= $row['id'] ?></td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <?php if ($row['logo']): ?>
                                        <img src="<?= $row['logo'] ?>" alt="" class="rounded-circle" width="40" height="40">
                                        <?php endif; ?>
                                        <div class="ms-2">
                                            <strong><?= $row['company_name'] ?></strong>
                                            <br><small class="text-muted"><?= $row['slug'] ?></small>
                                        </div>
                                    </div>
                                </td>
                                <td><?= $row['email'] ?></td>
                                <td><?= $row['phone'] ?></td>
                                <td><span class="badge bg-info"><?= $row['car_count'] ?></span></td>
                                <td><span class="badge bg-primary"><?= $row['booking_count'] ?></span></td>
                                <td><?= $row['commission_rate'] ?>%</td>
                                <td>
                                    <?php
                                    $badge = match($row['status']) {
                                        'active' => 'success',
                                        'pending' => 'warning',
                                        'suspended' => 'danger',
                                        default => 'secondary'
                                    };
                                    ?>
                                    <span class="badge bg-<?= $badge ?>"><?= ucfirst($row['status']) ?></span>
                                </td>
                                <td>
                                    <?php if ($row['is_verified']): ?>
                                    <span class="badge bg-success"><i class="bx bx-check"></i> Verified</span>
                                    <?php else: ?>
                                    <span class="badge bg-secondary">Unverified</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <div class="dropdown">
                                        <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                            Actions
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a class="dropdown-item" href="company_details.php?id=<?= $row['id'] ?>"><i class="bx bx-show"></i> View Details</a></li>
                                            <li><a class="dropdown-item" href="company_documents.php?id=<?= $row['id'] ?>"><i class="bx bx-file"></i> Documents</a></li>
                                            <li><hr class="dropdown-divider"></li>
                                            <?php if ($row['status'] != 'active'): ?>
                                            <li><a class="dropdown-item text-success" href="?action=activate&id=<?= $row['id'] ?>"><i class="bx bx-check"></i> Activate</a></li>
                                            <?php endif; ?>
                                            <?php if ($row['status'] != 'suspended'): ?>
                                            <li><a class="dropdown-item text-warning" href="?action=suspend&id=<?= $row['id'] ?>"><i class="bx bx-block"></i> Suspend</a></li>
                                            <?php endif; ?>
                                            <?php if (!$row['is_verified']): ?>
                                            <li><a class="dropdown-item text-info" href="?action=verify&id=<?= $row['id'] ?>"><i class="bx bx-badge-check"></i> Verify</a></li>
                                            <?php endif; ?>
                                            <li><hr class="dropdown-divider"></li>
                                            <li><a class="dropdown-item text-danger" href="?action=delete&id=<?= $row['id'] ?>" onclick="return confirm('Delete this company?')"><i class="bx bx-trash"></i> Delete</a></li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <?php
                $total_pages = ceil($total / $limit);
                if ($total_pages > 1):
                ?>
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <?php for ($i = 1; $i <= $total_pages; $i++): ?>
                        <li class="page-item <?= $i == $page ? 'active' : '' ?>">
                            <a class="page-link" href="?page=<?= $i ?>&status=<?= $_GET['status'] ?? '' ?>&search=<?= $_GET['search'] ?? '' ?>"><?= $i ?></a>
                        </li>
                        <?php endfor; ?>
                    </ul>
                </nav>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<?php require 'inc/footer.php'; ?>
